#!/usr/bin/env python3
import json, os, requests
from pathlib import Path

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
AGENT_MANIFEST = Path.home() / "genesis" / "agents" / "manifest.json"

def register_agents():
    with open(AGENT_MANIFEST) as f:
        agents = json.load(f)["agents"]

    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json"
    }

    for agent in agents:
        payload = {
            "name": agent["name"],
            "role": agent["role"],
            "path": agent["path"],
            "status": agent["status"],
            "trust_level": agent["trust_level"]
        }
        res = requests.post(f"{SUPABASE_URL}/rest/v1/agents_registry", headers=headers, json=payload)
        if res.status_code in (200, 201):
            print(f"✅ Registered: {agent['name']}")
        else:
            print(f"⚠️ Failed: {agent['name']} → {res.text}")

if __name__ == "__main__":
    register_agents()
