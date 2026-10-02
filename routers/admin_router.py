from fastapi import APIRouter, Form
from services.admin_service import (
    get_statistics,
    get_all_users,
    set_user_status
)

router = APIRouter(prefix="/admin", tags=["管理后台"])

# ========== 数据统计 ==========
@router.get("/statistics")
def admin_statistics():
    """管理后台首页统计数据"""
    return get_statistics()

# ========== 用户列表 ==========
@router.get("/users")
def admin_users():
    """获取全部用户列表"""
    return get_all_users()

# ========== 设置用户状态 ==========
@router.post("/user/set-status")
def admin_set_status(
    account: str = Form(...),
    status: str = Form(...)
):
    """冻结/解冻用户账号"""
    return set_user_status(account, status)