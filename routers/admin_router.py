from fastapi import APIRouter, Query, HTTPException
from pydantic import BaseModel, Field
from services.admin_service import AdminService

router = APIRouter(prefix="/admin", tags=["管理接口"])

# ========== 请求/响应模型 ==========
class StatusReq(BaseModel):
    frozen: bool = Field(..., description="是否冻结")

class VerifyReq(BaseModel):
    is_pass: bool = Field(..., description="是否通过审核")  # ✅ pass 是关键字 → 改为 is_pass
    remark: str | None = Field(None, description="审核备注")

# ========== 1. 数据统计 /admin/stats ==========
@router.get("/stats")
def get_system_stats():
    """获取系统统计数据"""
    try:
        return {
            "code": 200,
            "msg": "获取成功",
            "data": AdminService.get_system_stats()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"查询失败：{str(e)}")

# ========== 2. 用户列表 /admin/users ==========
@router.get("/users")
def get_user_list(
    page: int = Query(1, description="页码"),
    limit: int = Query(20, description="每页数量")
):
    """获取用户列表（分页）"""
    try:
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"查询失败：{str(e)}")

# ========== 3. 删除用户 /admin/users/{user_id}/delete ==========
@router.post("/users/{user_id}/delete")
def delete_user(user_id: int):
    """删除指定用户"""
    try:
        ok = AdminService.delete_user_by_id(user_id)
        if not ok:
            raise HTTPException(status_code=404, detail="用户不存在")
        return {"code": 200, "msg": "删除成功"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"删除失败：{str(e)}")

# ========== 4. 冻结/解冻用户 /admin/users/{user_id}/status ==========
@router.post("/users/{user_id}/status")
def update_user_status(user_id: int, req: StatusReq):
    """更新用户状态 —— 冻结/解冻"""
    try:
        ok = AdminService.update_user_frozen_status(user_id, req.frozen)
        if not ok:
            raise HTTPException(status_code=404, detail="用户不存在")
        return {
            "code": 200,
            "msg": "已冻结" if req.frozen else "已解冻",
            "data": {"frozen": req.frozen}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"操作失败：{str(e)}")

# ========== 5. 审核用户 /admin/users/{user_id}/verify ==========
@router.post("/users/{user_id}/verify")
def verify_user(user_id: int, req: VerifyReq):
    """审核用户身份认证"""
    try:
        ok = AdminService.verify_user_by_id(user_id, req.is_pass, req.remark)
        if not ok:
            raise HTTPException(status_code=404, detail="用户不存在")
        return {
            "code": 200,
            "msg": "审核通过" if req.is_pass else "已驳回",
            "data": {"verified": req.is_pass}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"审核失败：{str(e)}")