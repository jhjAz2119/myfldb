# user_service.py
from database import get_db_conn
from psycopg2.extras import RealDictCursor

class UserService:
    @staticmethod
    def _format_user(row):
        if not row:
            return None
        return {
            "account": row["account"],
            "nickname": row.get("nickname", row["account"]),
            "avatar": row.get("avatar", ""),
            "gender": row.get("gender", "未设置"),
            "birthday": row.get("birthday", ""),
            "user_id": row["id"],
            "created_at": row.get("created_at"),
            "id_verified": row.get("id_verified", False),
            "balance": float(row.get("balance", 0.00)),
        }

    @staticmethod
    def login(account: str, password: str):
        conn = get_db_conn()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(
            "SELECT * FROM users WHERE account = %s AND password = %s",
            (account, password)
        )
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user:
            return {"code": 200, "msg": "登录成功", "data": UserService._format_user(user)}
        return {"code": 400, "msg": "账号或密码错误"}

    @staticmethod
    def register(account: str, password: str):
        conn = get_db_conn()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT id FROM users WHERE account = %s", (account,))
        if cur.fetchone():
            cur.close()
            conn.close()
            return {"code": 400, "msg": "账号已存在"}
        cur.execute(
            "INSERT INTO users (account, password) VALUES (%s, %s) RETURNING id",
            (account, password)
        )
        res = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        return {"code": 200, "msg": "注册成功", "user_id": res["id"]}

    @staticmethod
    def update_profile(account: str, nickname, gender, birthday):
        conn = get_db_conn()
        cur = conn.cursor()
        updates = []
        params = []
        if nickname:
            updates.append("nickname = %s")
            params.append(nickname)
        if gender:
            updates.append("gender = %s")
            params.append(gender)
        if birthday:
            updates.append("birthday = %s")
            params.append(birthday)
        params.append(account)
        if updates:
            sql = f"UPDATE users SET {', '.join(updates)} WHERE account = %s"
            cur.execute(sql, params)
            conn.commit()
        cur.execute("SELECT * FROM users WHERE account = %s", (account,))
        row = cur.fetchone()
        cur.close()
        conn.close()
        if row:
            return {"code": 200, "msg": "保存成功", "data": UserService._format_user(row)}
        return {"code": 404, "msg": "用户不存在"}

    @staticmethod
    def change_password(account: str, old_pwd: str, new_pwd: str):
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute(
            "SELECT id FROM users WHERE account = %s AND password = %s",
            (account, old_pwd)
        )
        if not cur.fetchone():
            cur.close()
            conn.close()
            return {"code": 400, "msg": "原密码错误"}
        cur.execute(
            "UPDATE users SET password = %s WHERE account = %s",
            (new_pwd, account)
        )
        conn.commit()
        cur.close()
        conn.close()
        return {"code": 200, "msg": "密码修改成功"}

    @staticmethod
    def delete_account(account: str, password: str):
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute(
            "SELECT id FROM users WHERE account = %s AND password = %s",
            (account, password)
        )
        if not cur.fetchone():
            cur.close()
            conn.close()
            return {"code": 400, "msg": "密码验证失败"}
        cur.execute("DELETE FROM users WHERE account = %s", (account,))
        conn.commit()
        cur.close()
        conn.close()
        return {"code": 200, "msg": "账号已注销"}