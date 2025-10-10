#!/usr/bin/env python3
import json
import os
from pathlib import Path

MANIFEST_PATH = Path.home() / "genesis" / "agents" / "manifest.json"

def load_manifest():
    with open(MANIFEST_PATH) as f:
        return json.load(f)["agents"]

def check_agent(agent):
    path = os.path.expanduser(agent["path"])
    exists = os.path.exists(path)
    return {
        "name": agent["name"],
        "role": agent["role"],
        "status": "reachable" if exists else "missing",
        "trust_level": agent["trust_level"]
    }

if __name__ == "__main__":
    print("🔍 Scanning local Genesis agents...")
    manifest = load_manifest()
    report = [check_agent(a) for a in manifest]

    print("\n=== Infinity Fleet Status ===")
    for entry in report:
        print(f"🧩 {entry['name']} — {entry['role']} [{entry['status']}] Trust:{entry['trust_level']}")

    print("\n✅ Scan complete.")
