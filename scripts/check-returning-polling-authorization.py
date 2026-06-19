#!/usr/bin/env python3
import pathlib
import sys


source = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")

routes = (
    (
        "%% Returning XHR Polling",
        "%% Incoming XHR Polling data",
        "gen_server:cast(Pid, {'xhr-polling', polling_request, Req, From})",
    ),
    (
        "%% Returning JSONP Polling",
        "%% Incoming JSONP Polling data",
        "gen_server:cast(Pid, {'jsonp-polling', polling_request, {Req, Index}, From})",
    ),
)

for start, end, dispatch in routes:
    handler = source.split(start, 1)[1].split(end, 1)[0]
    contracts = (
        "case authorize_session_request(Req, State) of",
        "false ->",
        '405, "unauthorized"',
        "{ok, RequestOrigin} ->",
        "owned_session(Sessions, SessionId, RequestOrigin)",
        dispatch,
        '404, ""',
        "{noreply, State}",
    )
    for contract in contracts:
        if handler.count(contract) != 1:
            raise SystemExit(f"{start} must contain one {contract!r}.")
    if not all(handler.index(a) < handler.index(b) for a, b in zip(contracts, contracts[1:])):
        raise SystemExit(
            f"{start} must authorize and verify session ownership before dispatch."
        )

print("Returning polling authorization checks passed.")
