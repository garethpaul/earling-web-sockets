#!/usr/bin/env python3
import pathlib
import sys


source_path = pathlib.Path(sys.argv[1])
source = source_path.read_text(encoding="utf-8")
start_marker = "handle_call({_TransportType, data, Req}"
end_marker = "%% Event management"

if source.count(start_marker) != 1 or source.count(end_marker) != 1:
    raise SystemExit("Polling data handler boundaries must remain unique.")

handler = source.split(start_marker, 1)[1].split(end_marker, 1)[0]
cors = "case cors_headers(ServerModule:get_headers(Req), Sup) of"
unauthorized = "{false, _Headers} ->"
authorized = "{_, Headers} ->"
parse = "ServerModule:parse_post(Req)"
decode = "socketio_data:decode(#msg{content=Data})"

for contract in (cors, unauthorized, authorized, parse, decode):
    if handler.count(contract) != 1:
        raise SystemExit(f"Polling authorization contract must contain exactly one {contract!r}.")

cors_at = handler.index(cors)
unauthorized_at = handler.index(unauthorized)
authorized_at = handler.index(authorized)
parse_at = handler.index(parse)
decode_at = handler.index(decode)

if not cors_at < unauthorized_at < authorized_at < decode_at < parse_at:
    raise SystemExit("Polling POST data must be parsed and decoded only after Origin authorization.")

if parse in handler[unauthorized_at:authorized_at] or decode in handler[unauthorized_at:authorized_at]:
    raise SystemExit("Unauthorized polling POST handling must not parse or decode the request body.")
