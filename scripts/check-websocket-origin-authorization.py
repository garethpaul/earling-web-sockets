#!/usr/bin/env python3
import pathlib
import sys

misultin = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
http = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8")
start = 'handle_websocket_1(Server, Resource, ["websocket"|Resource], Ws) ->'
end = 'handle_websocket_1(_Server, _Resource, _WsResource, _Ws) ->'
handler = misultin.split(start, 1)[1].split(end, 1)[0]
contracts = ["misultin_ws:get(headers, Ws)", "gen_server:call(Server, {websocket, authorize, Headers})", "false ->", "{session, generate, {websocket, Ws}, socketio_transport_websocket}"]
for contract in contracts:
    if handler.count(contract) != 1:
        raise SystemExit(f"WebSocket authorization contract must contain one {contract!r}.")
if not all(handler.index(a) < handler.index(b) for a, b in zip(contracts, contracts[1:])):
    raise SystemExit("WebSocket Origin authorization must precede session generation.")
server = http.split("handle_call({websocket, authorize, Headers}", 1)[1].split("%% Sessions", 1)[0]
for contract in ("socketio_listener:verify_origin_headers(", "socketio_listener:origins(listener(State))"):
    if server.count(contract) != 1:
        raise SystemExit(f"HTTP WebSocket authorization must retain {contract!r}.")
