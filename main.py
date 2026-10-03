# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from database import init_database
from routers import user_router, admin_router

# 初始化数据库表结构
init_database()

app = FastAPI(title="用户管理系统", version="1.0.0")

# 跨域配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(user_router)
app.include_router(admin_router)

# 静态文件服务（必须放最后）
if os.path.exists("web"):
    app.mount("/", StaticFiles(directory="web", html=True), name="static")
if os.path.exists("uploads"):
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")