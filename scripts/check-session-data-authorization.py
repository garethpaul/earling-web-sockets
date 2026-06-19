#!/usr/bin/env python3
import pathlib
import sys


source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")

routes = (
    ("%% Incoming XHR Polling data", "%% New JSONP Polling request", "'xhr-polling'"),
    ("%% Incoming JSONP Polling data", "%% New XHR Multipart request", "'jsonp-polling'"),
    ("%% Incoming XHR Multipart data", "%% New htmlfile request", "'xhr-multipart'"),
    ("%% Incoming htmlfile data", "%% If we can't route it", "'htmlfile'"),
)

for start, end, transport in routes:
    handler = source.split(start, 1)[1].split(end, 1)[0]
    dispatch = f"handle_session_data({transport}, SessionId, Req, State)"
    if handler.count(dispatch) != 1:
        raise SystemExit(f"{start} must delegate once through {dispatch}.")
    if "ets:lookup" in handler or "gen_server:call(Pid" in handler:
        raise SystemExit(f"{start} must not inspect or dispatch sessions before authorization.")

helper = source.split("handle_session_data(Transport, SessionId, Req,", 1)[1]
helper = helper.split("\nauthorize_session_request(Req, #state", 1)[0]
contracts = (
    "case authorize_session_request(Req, State) of",
    "false ->",
    '405, "unauthorized"',
    "{ok, RequestOrigin} ->",
    "owned_session(Sessions, SessionId, RequestOrigin)",
    "socketio_request_security:post_body_status(ServerModule:get_headers(Req))",
    "gen_server:call(Pid, {Transport, data, Req})",
    '404, ""',
)
for contract in contracts:
    if helper.count(contract) != 1:
        raise SystemExit(f"Session data helper must contain one {contract!r}.")
if not all(helper.index(a) < helper.index(b) for a, b in zip(contracts, contracts[1:])):
    raise SystemExit("Session data helper must authorize, verify ownership, and bound the body before dispatch.")

print("Session data authorization checks passed.")
