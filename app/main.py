from fastapi import FastAPI
import requests
from db import get_conn

app = FastAPI()

@app.get("/geo")
def geo():
    ip = requests.get("https://api.ipify.org").text
    geo_data = requests.get(f"http://ip-api.com/json/{ip}").json()

    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        "INSERT INTO geo_logs (ip, country, city) VALUES (%s, %s, %s)",
        (ip, geo_data.get("country"), geo_data.get("city"))
    )
    conn.commit()

    cur.close()
    conn.close()

    return {
        "ip": ip,
        "country": geo_data.get("country"),
        "city": geo_data.get("city")
    }


# --- simple metric endpoint (next step for Prometheus) ---
@app.get("/metrics")
def metrics():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM geo_logs")
    count = cur.fetchone()[0]
    cur.close()
    conn.close()

    return {
        "geo_requests_total": count
    }
