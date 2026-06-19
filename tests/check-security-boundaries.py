#!/usr/bin/env python3
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]
HTTP = (ROOT / "src/socketio_http.erl").read_text()
MISULTIN = (ROOT / "src/socketio_http_misultin.erl").read_text()
WORKFLOW = (ROOT / ".github/workflows/check.yml").read_text()
TLS_TEST = (ROOT / "tests/check-demo-tls-fixture.sh").read_text()


def require_order(source: str, first: str, second: str, label: str) -> None:
    first_index = source.find(first)
    second_index = source.find(second)
    if first_index < 0 or second_index < 0 or first_index >= second_index:
        raise SystemExit(f"{label}: expected {first!r} before {second!r}")


for required in (
    "socketio_request_security:valid_session_id(SessionId)",
    "socketio_request_security:post_body_status(ServerModule:get_headers(Req))",
    "socketio_request_security:same_session_origin(SessionOrigin, RequestOrigin)",
    "[{SessionId, Pid, SessionOrigin}]",
    "ets:insert(Sessions, [{UUID, Pid, Origin}, {Pid, UUID}])",
    "socketio_request_security:valid_jsonp_index(Index)",
):
    if required not in HTTP:
        raise SystemExit(f"missing HTTP security contract: {required}")

owned_session = HTTP.split("owned_session(Sessions, SessionId, RequestOrigin) ->", 1)[1]
session_data = HTTP.split("handle_session_data(Transport, SessionId, Req,", 1)[1]
jsonp_new = HTTP.split("%% New JSONP Polling request", 1)[1].split(
    "%% Returning JSONP Polling", 1
)[0]

require_order(
    owned_session,
    "socketio_request_security:valid_session_id(SessionId)",
    "ets:lookup(Sessions, SessionId)",
    "session ID validation",
)
require_order(
    session_data,
    "socketio_request_security:post_body_status(ServerModule:get_headers(Req))",
    "gen_server:call(Pid, {Transport, data, Req})",
    "POST body validation",
)
require_order(
    jsonp_new,
    "socketio_request_security:valid_jsonp_index(Index)",
    "{session, generate, {'jsonp-polling'",
    "JSONP callback validation",
)

if "{session, generate, {websocket, Ws}, socketio_transport_websocket, Origin}" not in MISULTIN:
    raise SystemExit("WebSocket session creation must carry the authorized origin identity")

if "Run executable Erlang security tests" not in WORKFLOW:
    raise SystemExit("hosted workflow must execute the Erlang security tests")

if "sed -i" in TLS_TEST:
    raise SystemExit("TLS regression tests must not use non-portable sed -i")

tree = subprocess.check_output(
    ["git", "ls-files", "--stage", "priv/Socket.IO"], cwd=ROOT, text=True
).strip()
expected = "160000 7a5197c1e74d1f3a050b330e41e4b6e63afb209c 0\tpriv/Socket.IO"
if tree != expected:
    raise SystemExit(f"Socket.IO client gitlink is not pinned: {tree!r}")

print("Earling security boundary checks passed.")
