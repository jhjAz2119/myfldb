from database import get_db_connection


# ========== 数据统计 ==========
def get_statistics():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # 1. 用户总数
        cur.execute("SELECT COUNT(*) FROM users")
        total_users = cur.fetchone()[0]

        # 2. 今日注册
        cur.execute("SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURRENT_DATE")
        today_reg = cur.fetchone()[0]

        # 3. 待审核
        cur.execute("SELECT COUNT(*) FROM users WHERE verify_status = '待审核'")
        pending_verify = cur.fetchone()[0]

        # 4. 资金总额
        cur.execute("SELECT COALESCE(SUM(balance), 0) FROM users")
        total_fund = cur.fetchone()[0]

        return {
            "code": 200,
            "success": True,
            "total_users": total_users,
            "today_reg": today_reg,
            "pending_verify": pending_verify,
            "total_fund": float(total_fund)
        }
    except Exception as e:
        return {"code": 500, "success": False, "message": f"统计失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()


# ========== 获取所有用户列表 ==========
def get_all_users():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("""
            SELECT id, account, nickname, created_at AS register_time, status, verify_status
            FROM users ORDER BY id DESC
        """)
        users = cur.fetchall()
        return {
            "code": 200,
            "success": True,
            "data": [dict(u) for u in users]
        }
    except Exception as e:
        return {"code": 500, "success": False, "message": f"查询失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()


# ========== 设置用户状态（冻结/正常） ==========
def set_user_status(account: str, status: str):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("UPDATE users SET status = %s WHERE account = %s", (status, account))
        if cur.rowcount == 0:
            return {"code": 404, "success": False, "msg": "用户不存在"}
        conn.commit()
        return {"code": 200, "success": True, "msg": f"状态已更新为：{status}"}
    except Exception as e:
        conn.rollback()
        return {"code": 500, "success": False, "msg": f"操作失败: {str(e)}"}
    finally:
        cur.close()
        conn.close()