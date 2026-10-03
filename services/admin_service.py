from database import get_db_conn
from psycopg2.extras import RealDictCursor

class AdminService:
    """管理员相关业务逻辑"""

    @staticmethod
    def get_user_count():
        """获取系统用户总数"""
        conn = None
        try:
            conn = get_db_conn()
            cur = conn.cursor()
            cur.execute("SELECT COUNT(*) FROM users")
            count = cur.fetchone()[0]
            return count
        except Exception as e:
            print(f"❌ get_user_count 错误: {e}")
            return 0
        finally:
            if conn:
                conn.close()

    @staticmethod
    def get_all_users(limit: int = 20, offset: int = 0):
        """
        获取用户列表（管理用，支持分页）
        返回: (用户列表, 总数)
        """
        conn = None
        try:
            conn = get_db_conn()
            cur = conn.cursor(cursor_factory=RealDictCursor)
            # ✅ 完整字段，前端直接读取无缺失
            cur.execute("""
                SELECT 
                    id, account, nickname, avatar, gender, birthday,
                    created_at, id_verified, balance, frozen
                FROM users
                ORDER BY created_at DESC
                LIMIT %s OFFSET %s
            """, (limit, offset))
            users = cur.fetchall()

            cur.execute("SELECT COUNT(*) FROM users")
            total = cur.fetchone()[0]

            return users, total
        except Exception as e:
            print(f"❌ get_all_users 错误: {e}")
            return [], 0
        finally:
            if conn:
                conn.close()

    @staticmethod
    def get_system_stats():
        """获取系统统计信息"""
        conn = None
        try:
            total_users = AdminService.get_user_count()
            conn = get_db_conn()
            cur = conn.cursor()

            # 已认证用户
            cur.execute("SELECT COUNT(*) FROM users WHERE id_verified = TRUE")
            verified_count = cur.fetchone()[0]

            # 资金总额（处理空值）
            cur.execute("SELECT COALESCE(SUM(balance), 0) FROM users")
            total_balance = float(cur.fetchone()[0])

            return {
                "total_users": total_users,
                "verified_users": verified_count,
                "unverified_users": total_users - verified_count,
                "total_balance": round(total_balance, 2),
            }
        except Exception as e:
            print(f"❌ get_system_stats 错误: {e}")
            return {
                "total_users": 0,
                "verified_users": 0,
                "unverified_users": 0,
                "total_balance": 0.00,
            }
        finally:
            if conn:
                conn.close()

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
        except Exception as e:
            print(f"❌ delete_user_by_id 错误: {e}")
            return False
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
        except Exception as e:
            print(f"❌ update_user_frozen_status 错误: {e}")
            return False
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
        except Exception as e:
            print(f"❌ verify_user_by_id 错误: {e}")
            return False
        finally:
            if conn:
                conn.close()