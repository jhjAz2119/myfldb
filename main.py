from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import time

app = FastAPI()

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

    # 确保 avatar 字段存在
    cur.execute("""
        ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar TEXT;
    """)

    conn.commit()
    cur.close()
    conn.close()

init_db()

# 头像上传目录
UPLOAD_DIR = "uploads/avatars"
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/avatars", StaticFiles(directory=UPLOAD_DIR), name="avatars")

@app.post("/register")
def register(req: RegisterReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id FROM users WHERE account = %s",
            (req.account,)
        )
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

class UpdateProfileReq(BaseModel):
    account: str
    nickname: str = None
    gender: str = None
    birthday: str = None

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

# 上传头像接口
@app.post("/upload-avatar")
async def upload_avatar(
    account: str = Query(None),  # 方式1：URL 参数
    account_form: str = Form(None, alias="account"),  # 方式2：表单字段
    file: UploadFile = File(...)
):
    # 优先用 form-data，没有就用 query
    final_account = account_form if account_form else account
    
    if not final_account:
        raise HTTPException(status_code=422, detail="account 必填")
    
    # ========== 下面是你原来的保存文件逻辑，保持不变 ==========
    # 读取文件内容
    file_content = await file.read()
    
    # 保存路径（根据你实际情况改）
    import os
    save_dir = "uploads/avatars"
    os.makedirs(save_dir, exist_ok=True)
    
    import uuid
    ext = os.path.splitext(file.filename or "avatar.jpg")[-1] or ".jpg"
    save_filename = f"{final_account}_{uuid.uuid4().hex[:8]}{ext}"
    save_path = os.path.join(save_dir, save_filename)
    
    with open(save_path, "wb") as f:
        f.write(file_content)
    
    # 生成访问地址
    avatar_url = f"/uploads/avatars/{save_filename}"
    
    # 更新数据库
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE users SET avatar = %s WHERE account = %s",
        (avatar_url, final_account)
    )
    conn.commit()
    conn.close()
    
    return {
        "code": 200,
        "msg": "头像上传成功",
        "avatarUrl": avatar_url
    }

# 版本信息接口
@app.get("/version-info", summary="获取版本信息")
def get_version_info():
    return {
        "currentVersion": "1.0.0",
        "latestVersion": "1.0.0",
        "downloadUrl": "",
        "updateNote": "1. 优化个人信息页面\n2. 修复生日选择问题\n3. 提升登录稳定性"
    }