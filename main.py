from fastapi import FastAPI, HTTPException, Query, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
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
    "password": "OOTWPUjbdhe75miJFMEedks9MPby8z",
    "database": "myfldb",
}

# === 数据模型 ===
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

# === 工具函数 ===
def get_db_conn():
    return psycopg2.connect(**DB_CONFIG)

# === 接口 ===
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

@app.get("/version-info")
def version_info():
    return {
        "code": 200,
        "current": "1.0.0",
        "latest": "1.0.0",
        "download_url": "https://github.com/jhjAz2119/myfldb/releases/download/v1.0.0/app-release.apk",
    }

# 上传头像等其他接口...

# 静态文件 —— 放最后！
if os.path.exists("web"):
    app.mount("/", StaticFiles(directory="web", html=True), name="static")
if os.path.exists("uploads"):
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")