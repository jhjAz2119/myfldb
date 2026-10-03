# routers/user_router.py
from fastapi import APIRouter, HTTPException, Query, Form, UploadFile, File
import os
import uuid
from models import LoginReq, RegisterReq, UpdateProfileReq, ChangePwdReq, DeleteAccountReq
from user_service import UserService
from config import UPLOAD_DIR, VERSION, DOWNLOAD_URL
from database import get_db_conn

router = APIRouter(prefix="", tags=["用户接口"])

@router.post("/login")
def login(req: LoginReq):
    res = UserService.login(req.account, req.password)
    if res["code"] == 200:
        return {"code": 200, "msg": res["msg"], **res["data"]}
    return res

@router.post("/register")
def register(req: RegisterReq):
    return UserService.register(req.account, req.password)

@router.post("/update_profile")
def update_profile(req: UpdateProfileReq):
    res = UserService.update_profile(req.account, req.nickname, req.gender, req.birthday)
    if res["code"] == 200 and "data" in res:
        return {"code": 200, "msg": res["msg"], **res["data"]}
    return res

@router.post("/change_password")
def change_password(req: ChangePwdReq):
    return UserService.change_password(req.account, req.old_password, req.new_password)

@router.post("/delete_account")
def delete_account(req: DeleteAccountReq):
    return UserService.delete_account(req.account, req.password)

@router.post("/upload-avatar")
async def upload_avatar(
    account: str = Query(None),
    account_form: str = Form(None, alias="account"),
    file: UploadFile = File(...)
):
    final_account = account_form if account_form else account
    if not final_account:
        raise HTTPException(status_code=422, detail="account 必填")
    try:
        content = await file.read()
        ext = os.path.splitext(file.filename or "avatar.jpg")[-1]
        if not ext:
            ext = ".jpg"
        filename = f"{final_account}_{uuid.uuid4().hex[:8]}{ext}"
        path = os.path.join(UPLOAD_DIR, filename)
        with open(path, "wb") as f:
            f.write(content)
        avatar_url = f"/uploads/avatars/{filename}"
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute(
            "UPDATE users SET avatar = %s WHERE account = %s",
            (avatar_url, final_account)
        )
        conn.commit()
        cur.close()
        conn.close()
        return {"code": 200, "msg": "头像上传成功", "avatarUrl": avatar_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"上传失败: {str(e)}")

@router.get("/version-info")
def version_info():
    return {
        "currentVersion": VERSION,
        "latestVersion": VERSION,
        "downloadUrl": DOWNLOAD_URL,
        "updateNote": "完整模块化 + 管理接口 + 新增3字段",
    }