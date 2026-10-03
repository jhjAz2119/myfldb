from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

# 初始化数据库（建表/补字段）
from database import init_db
init_db()

# 导入路由
from routers.user_router import router as user_router
from routers.admin_router import router as admin_router

app = FastAPI(title="用户管理系统", version="1.0.0")

# 跨域配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



# 注册接口路由
app.include_router(user_router)
app.include_router(admin_router)
# 静态文件：Flutter 网页前端
if os.path.exists("web"):
    app.mount("/", StaticFiles(directory="web", html=True), name="static")

# 静态文件：头像等上传资源
if os.path.exists("uploads"):
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")