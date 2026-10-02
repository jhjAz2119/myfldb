from pydantic import BaseModel, Field
from typing import Optional


# ========== 用户相关请求模型 ==========
class RegisterReq(BaseModel):
    """注册请求格式"""
    account: str = Field(..., min_length=1, max_length=100, description="账号")
    password: str = Field(..., min_length=1, description="密码")


class LoginReq(BaseModel):
    """登录请求格式"""
    account: str = Field(..., description="账号")
    password: str = Field(..., description="密码")


class UpdateProfileReq(BaseModel):
    """更新资料请求格式 —— 字段可选，只传要改的"""
    account: str = Field(..., description="账号")
    nickname: Optional[str] = Field(None, description="昵称")
    gender: Optional[str] = Field(None, description="性别")
    birthday: Optional[str] = Field(None, description="生日")


class ChangePwdReq(BaseModel):
    """修改密码请求格式"""
    account: str = Field(..., description="账号")
    old_password: str = Field(..., description="原密码")
    new_password: str = Field(..., min_length=1, description="新密码")


class DeleteAccountReq(BaseModel):
    """注销账号请求格式"""
    account: str = Field(..., description="账号")
    password: str = Field(..., description="密码")


# ========== 管理后台相关请求模型 ==========
class SetUserStatusReq(BaseModel):
    """设置用户状态请求格式"""
    account: str = Field(..., description="目标账号")
    status: str = Field(..., description="状态值：正常/冻结等")