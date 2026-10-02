from fastapi import FastAPI, HTTPException, Query, Form, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import uuid
from datetime import datetime

app = FastAPI()

# ========== ✅ 关键修复：Flutter 网页挂载放最前面 ==========
if os.path.exists("build/web"):
    app.mount("/", StaticFiles(directory="build/web", html=True), name="static")

# ========== 上传文件挂载 ==========
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
# ❌ 删除重复：app.mount("/uploads/avatars", ...) 保留上面一行即可

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_CONFIG = {
    "host": "dpg-daudfcegekts73e1alfg-a.singapore-postgres.render.com",
    "port": 5432,
    "user": "myfldb_user",
    "password": "OOTWPUjbdhe75miJFMEedks9MPby8zUE",
    "database": "myfldb",
    "cursor_factory": RealDictCursor,
    "sslmode": "require"
}

class RegisterReq(BaseModel):
    account: str
    password: str

class LoginReq(BaseModel):
    account: str
    password: str

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            account VARCHAR(100) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            nickname VARCHAR(100),
            avatar TEXT,
            gender VARCHAR(20) DEFAULT '未设置',
            birthday VARCHAR(20),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar TEXT;")
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT '正常';")
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS verify_status VARCHAR(20) DEFAULT '未提交';")
    conn.commit()
    cur.close()
    conn.close()

init_db()

UPLOAD_DIR = "uploads/avatars"
os.makedirs(UPLOAD_DIR, exist_ok=True)

class UpdateProfileReq(BaseModel):
    account: str
    nickname: str = None
    gender: str = None
    birthday: str = None

@app.post("/register")
def register(req: RegisterReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT id FROM users WHERE account = %s", (req.account,))
        if cur.fetchone():
            return {"code": 400, "msg": "账号已存在"}
        cur.execute(
            "INSERT INTO users (account, password, nickname) VALUES (%s, %s, %s) RETURNING id",
            (req.account, req.password, req.account)
        )
        user_id = cur.fetchone()["id"]
        conn.commit()
        return {"code": 200, "msg": "注册成功", "user_id": user_id, "account": req.account}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"注册失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()

@app.post("/login")
def login(req: LoginReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id, account, nickname, avatar, gender, birthday FROM users WHERE account = %s AND password = %s",
            (req.account, req.password)
        )
        user = cur.fetchone()
        if not user:
            return {"code": 401, "msg": "账号或密码错误"}
        return {
            "code": 200,
            "msg": "登录成功",
            "user_id": user["id"],
            "account": user["account"],
            "nickname": user["nickname"] or user["account"],
            "avatar": user["avatar"],
            "gender": user["gender"] or "未设置",
            "birthday": user["birthday"]
        }
    finally:
        cur.close()
        conn.close()

@app.post("/update_profile")
def update_profile(req: UpdateProfileReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        fields = []
        values = []
        if req.nickname is not None:
            fields.append("nickname = %s")
            values.append(req.nickname)
        if req.gender is not None:
            fields.append("gender = %s")
            values.append(req.gender)
        if req.birthday is not None:
            fields.append("birthday = %s")
            values.append(req.birthday)
        if not fields:
            return {"code": 400, "msg": "没有要更新的内容"}
        values.append(req.account)
        sql = f"UPDATE users SET {', '.join(fields)} WHERE account = %s"
        cur.execute(sql, values)
        conn.commit()
        return {"code": 200, "msg": "保存成功"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"保存失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()

class ChangePwdReq(BaseModel):
    account: str
    old_password: str
    new_password: str

@app.post("/change_password")
def change_password(req: ChangePwdReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id FROM users WHERE account = %s AND password = %s",
            (req.account, req.old_password)
        )
        if not cur.fetchone():
            return {"code": 401, "msg": "原密码错误"}
        cur.execute(
            "UPDATE users SET password = %s WHERE account = %s",
            (req.new_password, req.account)
        )
        conn.commit()
        return {"code": 200, "msg": "密码修改成功"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"修改失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()

class DeleteAccountReq(BaseModel):
    account: str
    password: str

@app.post("/delete_account")
def delete_account(req: DeleteAccountReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id FROM users WHERE account = %s AND password = %s",
            (req.account, req.password)
        )
        if not cur.fetchone():
            return {"code": 401, "msg": "密码错误"}
        cur.execute("DELETE FROM users WHERE account = %s", (req.account,))
        conn.commit()
        return {"code": 200, "msg": "账号已注销"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"注销失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()

@app.post("/upload-avatar")
async def upload_avatar(
    account: str = Query(None),
    account_form: str = Form(None, alias="account"),
    file: UploadFile = File(...)
):
    final_account = account_form if account_form else account
    if not final_account:
        raise HTTPException(status_code=422, detail="account 必填")
    file_content = await file.read()
    ext = os.path.splitext(file.filename or "avatar.jpg")[-1]
    if not ext:
        ext = ".jpg"
    save_filename = f"{final_account}_{uuid.uuid4().hex[:8]}{ext}"
    save_path = os.path.join(UPLOAD_DIR, save_filename)
    with open(save_path, "wb") as f:
        f.write(file_content)
    avatar_url = f"/uploads/avatars/{save_filename}"
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "UPDATE users SET avatar = %s WHERE account = %s",
            (avatar_url, final_account)
        )
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"数据库更新失败: {str(e)}")
    finally:
        cur.close()
        conn.close()
    return {"code": 200, "msg": "头像上传成功", "avatarUrl": avatar_url}

@app.get("/version-info")
def get_version_info():
    return {
        "currentVersion": "1.0.0",
        "latestVersion": "1.0.0",
        "downloadUrl": "",
        "updateNote": "1. 修复上传头像\n2. 统一PostgreSQL数据库\n3. 优化静态文件访问"
    }

@app.get("/admin/users")
def admin_get_all_users():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute("""
            SELECT id, account, nickname, created_at AS register_time, status, verify_status
            FROM users ORDER BY id DESC
        """)
        users = cur.fetchall()
        return {"code": 200, "success": True, "data": [dict(u) for u in users]}
    except Exception as e:
        return {"code": 500, "success": False, "message": f"查询失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()

@app.get("/admin/statistics")
def admin_get_statistics():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT COUNT(*) FROM users")
        total = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURRENT_DATE")
        today_new = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM users WHERE verify_status = '待审核'")
        pending_verify = cur.fetchone()[0]
        return {
            "code": 200,
            "success": True,
            "data": {
                "total_users": total,
                "today_new": today_new,
                "pending_verify": pending_verify,
                "system_status": "运行中"
            }
        }
    except Exception as e:
        return {"code": 500, "message": f"统计失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()

@app.post("/admin/user/set-status")
def admin_set_user_status(account: str = Form(...), status: str = Form(...)):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("UPDATE users SET status = %s WHERE account = %s", (status, account))
        if cur.rowcount == 0:
            return {"code": 404, "msg": "用户不存在"}
        conn.commit()
        return {"code": 200, "success": True, "msg": f"已设为：{status}"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"操作失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()