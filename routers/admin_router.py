from fastapi import APIRouter, Query
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
def get_user_list(
    page: int = Query(1, description="页码"),
    limit: int = Query(20, description="每页数量")
):
    """获取用户列表（分页）"""
    offset = (page - 1) * limit
    users, total = AdminService.get_all_users(limit, offset)
    return {
        "code": 200,
        "msg": "获取成功",
        "data": {
            "list": users,       # 当前页数据
            "total": total,      # 全部用户数
            "page": page,        # 当前页码
            "limit": limit       # 每页条数
        }
    }