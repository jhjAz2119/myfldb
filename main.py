from fastapi import FastAPI, HTTPException, Query, Form, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import os
import uuid

app = FastAPI(title="用户管理系统", version="1.0.0")

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
    "password": "OOTWPUjbdhe75miJFMEedks9MPby8z",
    "database": "myfldb",
}

UPLOAD_DIR = "uploads/avatars"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# ========== 数据模型 ==========
class LoginReq(BaseModel):
    account: str
    password: str

class RegisterReq(BaseModel):
    account: str
    password: str

class UpdateProfileReq(BaseModel):
    account: str
    nickname: str = None
    gender: str = None
    birthday: str = None

class ChangePwdReq(BaseModel):
    account: str
    old_password: str
    new_password: str

class DeleteAccountReq(BaseModel):
    account: str
    password: str

# ========== 工具函数 ==========
def get_db_conn():
    return psycopg2.connect(**DB_CONFIG)

# ========== 登录 ==========
@app.post("/login")
def login(req: LoginReq):
    conn = get_db_conn()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(
        "SELECT * FROM users WHERE account = %s AND password = %s",
        (req.account, req.password)
    )
    user = cur.fetchone()
    cur.close()
    conn.close()
    if user:
        return {
            "code": 200,
            "msg": "登录成功",
            "account": user["account"],
            "nickname": user.get("nickname", user["account"]),
            "avatar": user.get("avatar", ""),
            "gender": user.get("gender", "未设置"),
            "birthday": user.get("birthday", ""),
            "user_id": user.get("id"),
        }
    return {"code": 400, "msg": "账号或密码错误"}

# ========== 注册 ==========
@app.post("/register")
def register(req: RegisterReq):
    try:
        conn = get_db_conn()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT id FROM users WHERE account = %s", (req.account,))
        if cur.fetchone():
            cur.close()
            conn.close()
            return {"code": 400, "msg": "账号已存在"}
        cur.execute(
            "INSERT INTO users (account, password) VALUES (%s, %s) RETURNING id",
            (req.account, req.password)
        )
        user_id = cur.fetchone()["id"]
        conn.commit()
        cur.close()
        conn.close()
        return {"code": 200, "msg": "注册成功", "user_id": user_id}
    except Exception as e:
        return {"code": 500, "msg": f"注册失败：{str(e)}"}

# ========== 更新资料 ==========
@app.post("/update_profile")
def update_profile(req: UpdateProfileReq):
    try:
        conn = get_db_conn()
        cur = conn.cursor()
        updates = []
        params = []
        if req.nickname is not None:
            updates.append("nickname = %s")
            params.append(req.nickname)
        if req.gender is not None:
            updates.append("gender = %s")
            params.append(req.gender)
        if req.birthday is not None:
            updates.append("birthday = %s")
            params.append(req.birthday)
        params.append(req.account)
        if updates:
            sql = f"UPDATE users SET {', '.join(updates)} WHERE account = %s"
            cur.execute(sql, params)
            conn.commit()
        cur.execute(
            "SELECT account, nickname, avatar, gender, birthday, id FROM users WHERE account = %s",
            (req.account,)
        )
        row = cur.fetchone()
        cur.close()
        conn.close()
        if row:
            return {
                "code": 200,
                "msg": "保存成功",
                "account": row["account"],
                "nickname": row["nickname"] or row["account"],
                "avatar": row.get("avatar", ""),
                "gender": row.get("gender", "未设置"),
                "birthday": row.get("birthday", ""),
                "user_id": row["id"],
            }
        return {"code": 404, "msg": "用户不存在"}
    except Exception as e:
        return {"code": 500, "msg": f"更新失败：{str(e)}"}

# ========== 修改密码 ==========
@app.post("/change_password")
def change_password(req: ChangePwdReq):
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute(
        "SELECT id FROM users WHERE account = %s AND password = %s",
        (req.account, req.old_password)
    )
    if not cur.fetchone():
        cur.close()
        conn.close()
        return {"code": 400, "msg": "原密码错误"}
    cur.execute(
        "UPDATE users SET password = %s WHERE account = %s",
        (req.new_password, req.account)
    )
    conn.commit()
    cur.close()
    conn.close()
    return {"code": 200, "msg": "密码修改成功"}

# ========== 注销账号 ==========
@app.post("/delete_account")
def delete_account(req: DeleteAccountReq):
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute(
        "SELECT id FROM users WHERE account = %s AND password = %s",
        (req.account, req.password)
    )
    if not cur.fetchone():
        cur.close()
        conn.close()
        return {"code": 400, "msg": "密码验证失败"}
    cur.execute("DELETE FROM users WHERE account = %s", (req.account,))
    conn.commit()
    cur.close()
    conn.close()
    return {"code": 200, "msg": "账号已注销"}

# ========== 上传头像 ==========
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
    
    conn = get_db_conn()
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

# ========== 版本信息 ==========
@app.get("/version-info")
def get_version():
    return {
        "currentVersion": "1.0.0",
        "latestVersion": "1.0.0",
        "downloadUrl": "https://github.com/jhjAz2119/myfldb/releases/download/v1.0.0/app-release.apk",
        "updateNote": "1. 基础功能完善\n2. 头像上传支持",
    }

# ========== 静态文件 —— 必须放最后！ ==========
if os.path.exists("web"):
    app.mount("/", StaticFiles(directory="web", html=True), name="static")

if os.path.exists("uploads"):
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")