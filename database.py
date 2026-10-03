# database.py
import psycopg2
from psycopg2.extras import RealDictCursor
from config import DB_CONFIG, UPLOAD_DIR
import os

os.makedirs(UPLOAD_DIR, exist_ok=True)

def get_db_conn():
    return psycopg2.connect(**DB_CONFIG)

def init_database():
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            account VARCHAR(50) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL
        )
    """)
    try:
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS nickname VARCHAR(50)")
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar TEXT")
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR(20) DEFAULT '未设置'")
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS birthday DATE")
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS id_verified BOOLEAN DEFAULT FALSE")
        cur.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS balance NUMERIC(10,2) DEFAULT 0.00")
    except Exception:
        pass
    conn.commit()
    cur.close()
    conn.close()