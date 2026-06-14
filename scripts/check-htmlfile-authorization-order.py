#!/usr/bin/env python3
import pathlib
import sys


source_path = pathlib.Path(sys.argv[1])
source = source_path.read_text(encoding="utf-8")
start_marker = "handle_call({'htmlfile', data, Req}"
end_marker = "%% Event management"

if source.count(start_marker) != 1 or source.count(end_marker) != 1:
    raise SystemExit("HTMLFile data handler boundaries must remain unique.")

handler = source.split(start_marker, 1)[1].split(end_marker, 1)[0]
authorize = "case socketio_listener:verify_origin_headers("
unauthorized = "false ->"
authorized = "_ ->"
parse = "ServerModule:parse_post(Req)"
decode = "socketio_data:decode(#msg{content=Data})"
response = 'ServerModule:respond(Req, 405, "unauthorized")'

for contract in (authorize, unauthorized, authorized, parse, decode, response):
    if handler.count(contract) != 1:
        raise SystemExit(
            f"HTMLFile authorization contract must contain exactly one {contract!r}."
        )

authorize_at = handler.index(authorize)
unauthorized_at = handler.index(unauthorized)
response_at = handler.index(response)
authorized_at = handler.index(authorized)
decode_at = handler.index(decode)
parse_at = handler.index(parse)

if not authorize_at < unauthorized_at < response_at < authorized_at < decode_at < parse_at:
    raise SystemExit(
        "HTMLFile POST data must be parsed and decoded only after Origin authorization."
    )

if parse in handler[unauthorized_at:authorized_at] or decode in handler[unauthorized_at:authorized_at]:
    raise SystemExit("Unauthorized HTMLFile handling must not parse or decode the body.")
