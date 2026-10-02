from fastapi import APIRouter, Query, Form, UploadFile, File
from typing import Optional
import os
import uuid
from models import RegisterReq, LoginReq, UpdateProfileReq, ChangePwdReq, DeleteAccountReq
from services.user_service import (
    register_user,
    login_user,
    update_profile,
    change_password,
    delete_account
)
from config import UPLOAD_DIR

router = APIRouter(tags=["用户接口"])

# ========== 注册 ==========
@router.post("/register")
def register(req: RegisterReq):
    return register_user(req)

# ========== 登录 ==========
@router.post("/login")
def login(req: LoginReq):
    return login_user(req)

# ========== 更新资料 ==========
@router.post("/update_profile")
def update(req: UpdateProfileReq):
    return update_profile(req)

# ========== 修改密码 ==========
@router.post("/change_password")
def change_pwd(req: ChangePwdReq):
    return change_password(req)

# ========== 注销账号 ==========
@router.post("/delete_account")
def delete(req: DeleteAccountReq):
    return delete_account(req)

# ========== 上传头像 ==========
@router.post("/upload-avatar")
async def upload_avatar(
    account: str = Query(None),
    account_form: str = Form(None, alias="account"),
    file: UploadFile = File(...)
):
    final_account = account_form if account_form else account
    if not final_account:
        from fastapi import HTTPException
        raise HTTPException(status_code=422, detail="account 必填")
    
    file_content = await file.read()
    ext = os.path.splitext(file.filename or "avatar.jpg")[-1]
    if not ext:
        ext = ".jpg"
    
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    save_filename = f"{final_account}_{uuid.uuid4().hex[:8]}{ext}"
    save_path = os.path.join(UPLOAD_DIR, save_filename)
    
    with open(save_path, "wb") as f:
        f.write(file_content)
    
    avatar_url = f"/uploads/avatars/{save_filename}"
    
    # 更新数据库
    from database import get_db_connection
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "UPDATE users SET avatar = %s WHERE account = %s",
            (avatar_url, final_account)
        )
        conn.commit()
    except Exception as e:
        conn.rollback()
        from fastapi import HTTPException
        raise HTTPException(status_code=500, detail=f"数据库更新失败: {str(e)}")
    finally:
        cur.close()
        conn.close()
    
    return {"code": 200, "msg": "头像上传成功", "avatarUrl": avatar_url}

# ========== 版本信息 ==========
@router.get("/version-info")
def get_version():
    return {
        "currentVersion": "1.0.0",
        "latestVersion": "1.0.0",
        "downloadUrl": "",
        "updateNote": "1. 后端模块化重构\n2. 新增余额字段\n3. 管理后台统计接口"
    }