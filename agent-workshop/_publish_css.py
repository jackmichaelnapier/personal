#!/usr/bin/env python3
"""Quick single-file push of workshop.css to the live site."""
import base64, json, os, subprocess, sys, urllib.request, urllib.error

def resolve_token():
    t = os.environ.get("NAPIER_PUBLISH_TOKEN")
    if t: return t
    try:
        out = subprocess.run(["security", "find-generic-password", "-s", "napier-publish-token", "-w"],
                             capture_output=True, text=True, timeout=5)
        if out.returncode == 0 and out.stdout.strip(): return out.stdout.strip()
    except Exception: pass
    return None

TOKEN = resolve_token()
if not TOKEN: print("ERR no_token"); sys.exit(2)
OWNER, REPO = "jackmichaelnapier", "personal"
API = "https://api.github.com"
HERE = os.path.dirname(os.path.abspath(__file__))
LOCAL = os.path.join(HERE, "workshop.css")
REMOTE = "agent-workshop/workshop.css"

def gh(method, path, body=None):
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(API + path, data=data, method=method)
    req.add_header("Authorization", f"Bearer {TOKEN}")
    req.add_header("Accept", "application/vnd.github+json")
    if data: req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode() or "{}")

st, data = gh("GET", f"/repos/{OWNER}/{REPO}/contents/{REMOTE}")
sha = data.get("sha") if st == 200 else None

with open(LOCAL, "rb") as f: content = f.read()
body = {"message": "agent-workshop: fix card spacing inside studio forms",
        "content": base64.b64encode(content).decode(), "branch": "main"}
if sha: body["sha"] = sha

st, data = gh("PUT", f"/repos/{OWNER}/{REPO}/contents/{REMOTE}", body)
if 200 <= st < 300:
    print(f"OK pushed {REMOTE} sha={data.get('commit',{}).get('sha','?')[:7]} bytes={len(content)}")
else:
    print(f"ERR push_failed status={st}", file=sys.stderr); sys.exit(4)
