# services/admin_service.py
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
    def get_all_users(limit: int = 100):
        """获取用户列表（管理用）"""
        conn = get_db_conn()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("""
            SELECT id, account, nickname, created_at, id_verified, balance
            FROM users ORDER BY created_at DESC LIMIT %s
        """, (limit,))
        users = cur.fetchall()
        cur.close()
        conn.close()
        return users

    @staticmethod
    def get_system_stats():
        """获取系统统计信息"""
        total_users = AdminService.get_user_count()
        conn = get_db_conn()
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM users WHERE id_verified = TRUE")
        verified_count = cur.fetchone()[0]
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