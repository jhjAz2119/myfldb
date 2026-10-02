import psycopg2
from psycopg2.extras import RealDictCursor
from config import DB_CONFIG

def get_db_connection():
    """获取数据库连接，统一使用 RealDictCursor 方便按字段名读取"""
    config = DB_CONFIG.copy()
    config["cursor_factory"] = RealDictCursor
    return psycopg2.connect(**config)

def init_db():
    """初始化表结构与字段，程序启动时自动执行"""
    conn = get_db_connection()
    cur = conn.cursor()

    # 1. 创建用户表（不存在时才创建）
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            account VARCHAR(100) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            nickname VARCHAR(100),
            avatar TEXT,
            gender VARCHAR(20) DEFAULT '未设置',
            birthday VARCHAR(20),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # 2. 补充扩展字段（已存在不会重复创建）
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar TEXT;")
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT '正常';")
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS verify_status VARCHAR(20) DEFAULT '未提交';")
    cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS balance NUMERIC DEFAULT 0;")

    conn.commit()
    cur.close()
    conn.close()