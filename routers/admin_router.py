# routers/admin_router.py
from fastapi import APIRouter
from services.admin_service import AdminService

router = APIRouter(prefix="/admin", tags=["管理接口"])

@router.get("/stats")
def get_system_stats():
    """获取系统统计数据"""
    return {
        "code": 200,
        "msg": "获取成功",
        "data": AdminService.get_system_stats()
    }

@router.get("/users")
def get_user_list(limit: int = 100):
    """获取用户列表"""
    return {
        "code": 200,
        "msg": "获取成功",
        "data": AdminService.get_all_users(limit)
    }