CREATE_TABLE = """
CREATE TABLE IF NOT EXISTS geo_logs (
    id SERIAL PRIMARY KEY,
    ip TEXT,
    country TEXT,
    city TEXT
);
"""
