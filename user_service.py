from fastapi import HTTPException
from database import get_db_connection
from models import RegisterReq, LoginReq, UpdateProfileReq, ChangePwdReq, DeleteAccountReq


# ========== 注册 ==========
def register_user(req: RegisterReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT id FROM users WHERE account = %s", (req.account,))
        if cur.fetchone():
            return {"code": 400, "msg": "账号已存在"}
        
        cur.execute(
            "INSERT INTO users (account, password, nickname) VALUES (%s, %s, %s) RETURNING id",
            (req.account, req.password, req.account)
        )
        user_id = cur.fetchone()["id"]
        conn.commit()
        return {"code": 200, "msg": "注册成功", "user_id": user_id, "account": req.account}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"注册失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()


# ========== 登录 ==========
def login_user(req: LoginReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id, account, nickname, avatar, gender, birthday FROM users WHERE account = %s AND password = %s",
            (req.account, req.password)
        )
        user = cur.fetchone()
        if not user:
            return {"code": 401, "msg": "账号或密码错误"}
        
        return {
            "code": 200,
            "msg": "登录成功",
            "user_id": user["id"],
            "account": user["account"],
            "nickname": user["nickname"] or user["account"],
            "avatar": user["avatar"],
            "gender": user["gender"] or "未设置",
            "birthday": user["birthday"]
        }
    finally:
        cur.close()
        conn.close()


# ========== 更新资料 ==========
def update_profile(req: UpdateProfileReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        fields = []
        values = []
        
        if req.nickname is not None:
            fields.append("nickname = %s")
            values.append(req.nickname)
        if req.gender is not None:
            fields.append("gender = %s")
            values.append(req.gender)
        if req.birthday is not None:
            fields.append("birthday = %s")
            values.append(req.birthday)
        
        if not fields:
            return {"code": 400, "msg": "没有要更新的内容"}
        
        values.append(req.account)
        sql = f"UPDATE users SET {', '.join(fields)} WHERE account = %s"
        cur.execute(sql, values)
        conn.commit()
        return {"code": 200, "msg": "保存成功"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"保存失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()


# ========== 修改密码 ==========
def change_password(req: ChangePwdReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id FROM users WHERE account = %s AND password = %s",
            (req.account, req.old_password)
        )
        if not cur.fetchone():
            return {"code": 401, "msg": "原密码错误"}
        
        cur.execute(
            "UPDATE users SET password = %s WHERE account = %s",
            (req.new_password, req.account)
        )
        conn.commit()
        return {"code": 200, "msg": "密码修改成功"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"修改失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()


# ========== 注销账号 ==========
def delete_account(req: DeleteAccountReq):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT id FROM users WHERE account = %s AND password = %s",
            (req.account, req.password)
        )
        if not cur.fetchone():
            return {"code": 401, "msg": "密码错误"}
        
        cur.execute("DELETE FROM users WHERE account = %s", (req.account,))
        conn.commit()
        return {"code": 200, "msg": "账号已注销"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "msg": f"注销失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()