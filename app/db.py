import os
import psycopg2

def get_conn():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "postgresql"),
        database=os.getenv("POSTGRES_DB", "appdb"),
        user=os.getenv("POSTGRES_USER", "appuser"),
        password=os.getenv("POSTGRES_PASSWORD", "StrongPass")
    )
