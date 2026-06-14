#!/usr/bin/env python3
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")

routes = (
    ("%% New XHR Polling request", "%% Returning XHR Polling", "{'xhr-polling', Req}"),
    ("%% New JSONP Polling request", "%% Returning JSONP Polling", "{'jsonp-polling', {Req, Index}}"),
    ("%% New XHR Multipart request", "%% Incoming XHR Multipart data", "{'xhr-multipart', {Req, From}}"),
    ("%% New htmlfile request", "%% Incoming htmlfile data", "{'htmlfile', {Req, From}}"),
)

for start, end, connection in routes:
    handler = source.split(start, 1)[1].split(end, 1)[0]
    contracts = (
        "authorize_session_request(Req, State)",
        "false ->",
        "405, \"unauthorized\"",
        "handle_call({session, generate, " + connection,
    )
    for contract in contracts:
        if handler.count(contract) != 1:
            raise SystemExit(f"{start} must contain one {contract!r}.")
    if not all(handler.index(a) < handler.index(b) for a, b in zip(contracts, contracts[1:])):
        raise SystemExit(f"{start} must authorize before session generation.")

helper = source.split("authorize_session_request(Req, #state", 1)[1]
for contract in (
    "ServerModule:get_headers(Req)",
    "socketio_listener:verify_origin_headers(",
    "socketio_listener:origins(listener(State))",
    "false -> false",
    "_ -> true",
):
    if helper.count(contract) != 1:
        raise SystemExit(f"HTTP session authorization helper must contain one {contract!r}.")
