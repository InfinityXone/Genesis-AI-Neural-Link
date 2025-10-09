#!/usr/bin/env python3
"""
Genesis Hydration Core — Memory Sync & Supabase Bridge
"""

import os, json, time, hashlib
from datetime import datetime
from supabase import create_client, Client

# === Load environment ===
ENV_PATH = "/home/infinity-x-one/config/production.env"
def load_env(env_path):
    env = {}
    with open(env_path) as f:
        for line in f:
            if "=" in line:
                k, v = line.strip().split("=", 1)
                env[k] = v.strip('"')
    return env

env = load_env(ENV_PATH)
SUPABASE_URL = env.get("SUPABASE_URL")
SUPABASE_KEY = env.get("SUPABASE_SERVICE_ROLE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# === Paths ===
LOCAL_MEMORY = "/mnt/data/genesis/memory_cache/memory.json"
LOG_PATH = "/mnt/data/genesis/logs/hydrate.log"

os.makedirs(os.path.dirname(LOCAL_MEMORY), exist_ok=True)
os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)

def log(msg):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_PATH, "a") as f:
        f.write(f"[{ts}] {msg}\n")
    print(msg)

def checksum(path):
    if not os.path.exists(path): return None
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()

def fetch_remote_memory():
    try:
        data = supabase.table("memory").select("*").execute()
        if data.data:
            with open(LOCAL_MEMORY, "w") as f:
                json.dump(data.data, f, indent=2)
            log("🧠 Hydrated local memory from Supabase.")
    except Exception as e:
        log(f"[ERROR] Remote fetch failed: {e}")

def push_local_memory():
    try:
        with open(LOCAL_MEMORY) as f:
            data = json.load(f)
        for m in data:
            supabase.table("memory").upsert(m).execute()
        log("☁️ Pushed local memory to Supabase.")
    except Exception as e:
        log(f"[ERROR] Push failed: {e}")

def main():
    last_hash = checksum(LOCAL_MEMORY)
    while True:
        time.sleep(60)  # Run every 1 minute
        new_hash = checksum(LOCAL_MEMORY)

        if new_hash != last_hash:
            push_local_memory()
            last_hash = new_hash
        else:
            fetch_remote_memory()

if __name__ == "__main__":
    log("🚀 Genesis Hydration Core started.")
    main()
