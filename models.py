# models.py
from pydantic import BaseModel
from typing import Optional

class LoginReq(BaseModel):
    account: str
    password: str

class RegisterReq(BaseModel):
    account: str
    password: str

class UpdateProfileReq(BaseModel):
    account: str
    nickname: Optional[str] = None
    gender: Optional[str] = None
    birthday: Optional[str] = None

class ChangePwdReq(BaseModel):
    account: str
    old_password: str
    new_password: str

class DeleteAccountReq(BaseModel):
    account: str
    password: str

class AdminStatsReq(BaseModel):
    pass