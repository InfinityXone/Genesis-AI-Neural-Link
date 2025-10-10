#!/usr/bin/env python3
# ===============================================================
# Genesis Limitless Gateway — GPT ⇄ Orchestrator ⇄ Agents Bridge
# ===============================================================
from fastapi import FastAPI, Request
import subprocess, json, os, time

app = FastAPI(title="Genesis Limitless Gateway")

# === Health ===
@app.get("/health")
async def health():
    return {
        "status": "ok",
        "agent": "Genesis Core",
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
    }

# === Command Invocation ===
@app.post("/invoke")
async def invoke(request: Request):
    data = await request.json()
    cmd = data.get("cmd")
    if not cmd:
        return {"error": "missing command"}
    try:
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=120)
        return {
            "stdout": res.stdout.strip(),
            "stderr": res.stderr.strip(),
            "returncode": res.returncode
        }
    except Exception as e:
        return {"error": str(e)}

# === Memory Sync ===
@app.post("/memory")
async def memory(request: Request):
    payload = await request.json()
    mem_file = "/home/infinity-x-one/genesis/memory/genesis_memory.json"

    if payload.get("action") == "push":
        with open(mem_file, "w") as f:
            json.dump(payload.get("data", {}), f, indent=2)
        return {"status": "memory updated"}
    elif payload.get("action") == "pull":
        if not os.path.exists(mem_file):
            return {"error": "no memory yet"}
        return json.load(open(mem_file))
    else:
        return {"error": "invalid action"}

# === Fallback Command Execution ===
@app.post("/shell")
async def shell(request: Request):
    data = await request.json()
    cmd = data.get("cmd")
    if not cmd:
        return {"error": "no shell command"}
    out = subprocess.getoutput(cmd)
    return {"output": out}
