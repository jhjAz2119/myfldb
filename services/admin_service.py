from database import get_db_conn
from psycopg2.extras import RealDictCursor

class AdminService:
    """管理员相关业务逻辑"""

    @staticmethod
    def get_user_count():
        """获取系统用户总数"""
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM users")
        count = cur.fetchone()[0]
        cur.close()
        conn.close()
        return count

    @staticmethod
    def get_all_users(limit: int = 20, offset: int = 0):
        """
        获取用户列表（管理用，支持分页）
        返回: (用户列表, 总数)
        """
        conn = get_db_conn()
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # 分页数据
        cur.execute("""
            SELECT id, account, nickname, created_at, id_verified, balance
            FROM users
            ORDER BY created_at DESC
            LIMIT %s OFFSET %s
        """, (limit, offset))
        users = cur.fetchall()

        # 同时查询总数，用于分页
        cur.execute("SELECT COUNT(*) FROM users")
        total = cur.fetchone()[0]

        cur.close()
        conn.close()

        return users, total  # ✅ 返回双值：列表 + 总数

    @staticmethod
    def get_system_stats():
        """获取系统统计信息"""
        total_users = AdminService.get_user_count()

        conn = get_db_conn()
        cur = conn.cursor()

        # 已认证用户（字段用 id_verified，保持和你数据库一致）
        cur.execute("SELECT COUNT(*) FROM users WHERE id_verified = TRUE")
        verified_count = cur.fetchone()[0]

        # 资金总额
        cur.execute("SELECT COALESCE(SUM(balance), 0) FROM users")
        total_balance = float(cur.fetchone()[0])

        cur.close()
        conn.close()

        return {
            "total_users": total_users,
            "verified_users": verified_count,
            "unverified_users": total_users - verified_count,
            "total_balance": round(total_balance, 2),
        }
    @staticmethod
    def delete_user_by_id(user_id: int) -> bool:
        """根据ID删除用户，返回是否成功"""
        conn = None
        try:
            conn = get_db_conn()
            cur = conn.cursor()
            cur.execute("DELETE FROM users WHERE id = %s", (user_id,))
            conn.commit()
            return cur.rowcount > 0
        finally:
            if conn:
                conn.close()

    @staticmethod
    def update_user_frozen_status(user_id: int, frozen: bool) -> bool:
        """更新用户冻结状态"""
        conn = None
        try:
            conn = get_db_conn()
            cur = conn.cursor()
            cur.execute(
                "UPDATE users SET frozen = %s WHERE id = %s",
                (frozen, user_id)
            )
            conn.commit()
            return cur.rowcount > 0
        finally:
            if conn:
                conn.close()

    @staticmethod
    def verify_user_by_id(user_id: int, passed: bool, remark: str | None = None) -> bool:
        """审核用户 —— 更新认证状态"""
        conn = None
        try:
            conn = get_db_conn()
            cur = conn.cursor()
            cur.execute(
                "UPDATE users SET id_verified = %s WHERE id = %s",
                (passed, user_id)
            )
            conn.commit()
            return cur.rowcount > 0
        finally:
            if conn:
                conn.close()