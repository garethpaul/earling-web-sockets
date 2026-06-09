#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
SECURITY="$ROOT_DIR/SECURITY.md"
VISION="$ROOT_DIR/VISION.md"
MAKEFILE="$ROOT_DIR/Makefile"
GITIGNORE="$ROOT_DIR/.gitignore"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-earling-web-sockets-maintenance-baseline.md"
CHECK_PLAN="$ROOT_DIR/docs/plans/2026-06-08-earling-check-wrapper.md"
HEARTBEAT_PLAN="$ROOT_DIR/docs/plans/2026-06-08-earling-websocket-heartbeat-timers.md"
CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-demo-credential-boundary.md"
LONGPOLL_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-longpoll-timer-refs.md"
FRAME_DECODE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-malformed-frame-decode.md"
JSONP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-jsonp-index-guard.md"
LISTENER="$ROOT_DIR/src/socketio_listener.erl"
LISTENER_TESTS="$ROOT_DIR/test/socketio_listener_tests.erl"
DATA="$ROOT_DIR/src/socketio_data.erl"
WEBSOCKET="$ROOT_DIR/src/socketio_transport_websocket.erl"
XHR_MULTIPART="$ROOT_DIR/src/socketio_transport_xhr_multipart.erl"
HTMLFILE="$ROOT_DIR/src/socketio_transport_htmlfile.erl"
POLLING="$ROOT_DIR/src/socketio_transport_polling.erl"
DEMO="$ROOT_DIR/demo/demo.erl"

for path in \
  "README.md" \
  "SECURITY.md" \
  "VISION.md" \
  "Makefile" \
  "rebar.config" \
  ".gitignore" \
  "src/socketio.app.src" \
  "src/socketio_data.erl" \
  "src/socketio_listener.erl" \
  "src/socketio_transport_websocket.erl" \
  "demo/demo.erl" \
  "test/socketio_data_tests.erl" \
  "test/socketio_listener_tests.erl" \
  ".gitmodules" \
  "CHANGES.md" \
  "docs/plans/2026-06-09-earling-demo-credential-boundary.md" \
  "docs/plans/2026-06-09-earling-jsonp-index-guard.md" \
  "docs/plans/2026-06-09-earling-longpoll-timer-refs.md" \
  "docs/plans/2026-06-09-earling-malformed-frame-decode.md" \
  "docs/plans/2026-06-08-earling-check-wrapper.md" \
  "docs/plans/2026-06-08-earling-websocket-heartbeat-timers.md" \
  "docs/plans/2026-06-08-earling-web-sockets-maintenance-baseline.md"; do
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
done

if ! grep -Fq "Erlang/OTP" "$README" ||
  ! grep -Fq "escript" "$README" ||
  ! grep -Fq "make check" "$README" ||
  ! grep -Fq "make test" "$README" ||
  ! grep -Fq "Socket.IO 0.6" "$README" ||
  ! grep -Fq "test-only" "$README" ||
  ! grep -Fq "Malformed Socket.IO frames" "$README" ||
  ! grep -Fq "Malformed or relative Origin values" "$README"; then
  printf '%s\n' "README must document Erlang, escript, tests, legacy Socket.IO scope, demo certificate status, frame decode, and Origin handling." >&2
  exit 1
fi

if grep -Fq "static web project" "$README" ||
  grep -Fq "no obvious test files detected" "$README"; then
  printf '%s\n' "README must not contain stale scanner-generated project classification." >&2
  exit 1
fi

for ignore_entry in \
  "/.eunit/" \
  "/deps/" \
  "/ebin/" \
  "/logs/" \
  "/priv/Socket.IO/" \
  ".agner.config" \
  "erl_crash.dump"; do
  if ! grep -Fxq "$ignore_entry" "$GITIGNORE"; then
    printf '%s\n' ".gitignore must keep generated Erlang/rebar artifacts untracked: $ignore_entry" >&2
    exit 1
  fi
done

tracked_key_material=$(git -C "$ROOT_DIR" ls-files | grep -Ei '\.(pem|key)$' || true)
expected_key_material='demo/test_certificate.pem
demo/test_privkey.pem'

if [ "$tracked_key_material" != "$expected_key_material" ]; then
  printf '%s\n' "Only demo/test_certificate.pem and demo/test_privkey.pem may be tracked certificate/key material." >&2
  printf '%s\n%s\n' "Tracked certificate/key material:" "$tracked_key_material" >&2
  exit 1
fi

if ! grep -Fq "demo/test_certificate.pem" "$SECURITY" ||
  ! grep -Fq "demo/test_privkey.pem" "$SECURITY" ||
  ! grep -Fq "test-only" "$SECURITY"; then
  printf '%s\n' "SECURITY must document the demo-only certificate/key boundary." >&2
  exit 1
fi

if ! grep -Fq "demo/test_privkey.pem" "$README" ||
  ! grep -Fq "Do not commit production certificates" "$README"; then
  printf '%s\n' "README must document demo-only SSL material and production credential exclusions." >&2
  exit 1
fi

if ! grep -Fq "command -v erl" "$MAKEFILE" ||
  ! grep -Fq "command -v escript" "$MAKEFILE" ||
  ! grep -Fq "check: verify" "$MAKEFILE"; then
  printf '%s\n' "Makefile must preflight Erlang erl/escript before rebar targets and expose make check." >&2
  exit 1
fi

if ! grep -Fq "catch ex_uri:decode" "$ROOT_DIR/src/socketio_listener.erl" ||
  ! grep -Fq "Host =/= undefined" "$ROOT_DIR/src/socketio_listener.erl" ||
  ! grep -Fq "malformed_origin_rejected_test" "$ROOT_DIR/test/socketio_listener_tests.erl" ||
  ! grep -Fq "relative_origin_rejected_test" "$ROOT_DIR/test/socketio_listener_tests.erl"; then
  printf '%s\n' "Malformed Origin handling must remain covered by listener tests." >&2
  exit 1
fi

if ! grep -Fq "case catch ex_uri:decode(Origin)" "$LISTENER" ||
  ! grep -Fq 'when Host =/= undefined, Host =/= ""' "$LISTENER"; then
  printf '%s\n' "socketio_listener must reject malformed and hostless Origin values without crashing." >&2
  exit 1
fi

if ! grep -Fq "malformed_origin_rejected_test" "$LISTENER_TESTS" ||
  ! grep -Fq "relative_origin_rejected_test" "$LISTENER_TESTS"; then
  printf '%s\n' "socketio_listener_tests must cover malformed and relative Origin rejection." >&2
  exit 1
fi

if ! grep -Fq "stale_heartbeat_timer_is_ignored_test" "$WEBSOCKET" ||
  ! grep -Fq "handle_info({timeout, Ref, heartbeat}, #state{ heartbeat_interval = {Ref, _Time} } = State)" "$WEBSOCKET" ||
  ! grep -Fq "handle_info({timeout, _Ref, heartbeat}, State)" "$WEBSOCKET"; then
  printf '%s\n' "websocket heartbeat handling must ignore stale timer references." >&2
  exit 1
fi

if ! grep -Fq "stale_heartbeat_timer_is_ignored_test" "$XHR_MULTIPART" ||
  ! grep -Fq "connection_reference = {'xhr-multipart', connected}" "$XHR_MULTIPART" ||
  ! grep -Fq "heartbeat_interval = {Ref, _Time}" "$XHR_MULTIPART" ||
  ! grep -Fq "handle_info({timeout, _Ref, heartbeat}, #state{ connection_reference = {'xhr-multipart', connected} } = State)" "$XHR_MULTIPART"; then
  printf '%s\n' "xhr-multipart heartbeat handling must ignore stale timer references." >&2
  exit 1
fi

if ! grep -Fq "stale_heartbeat_timer_is_ignored_test" "$HTMLFILE" ||
  ! grep -Fq "connection_reference = {'htmlfile', connected}" "$HTMLFILE" ||
  ! grep -Fq "heartbeat_interval = {Ref, _Time}" "$HTMLFILE" ||
  ! grep -Fq "handle_info({timeout, _Ref, heartbeat}, #state{ connection_reference = {'htmlfile', connected} } = State)" "$HTMLFILE"; then
  printf '%s\n' "htmlfile heartbeat handling must ignore stale timer references." >&2
  exit 1
fi

if ! grep -Fq "stale_polling_timer_is_ignored_test" "$POLLING" ||
  ! grep -Fq "polling_duration = {Ref, _Time}" "$POLLING" ||
  ! grep -Fq "handle_info({timeout, _Ref, polling}, #state{ connection_reference = {_TransportType, connected} } = State)" "$POLLING"; then
  printf '%s\n' "polling duration handling must ignore stale timer references." >&2
  exit 1
fi

if ! grep -Fq "safe_jsonp_index(Index)" "$POLLING" ||
  ! grep -Fq "invalid jsonp index" "$POLLING" ||
  ! grep -Fq "jsonp_index_rejects_script_characters_test" "$POLLING"; then
  printf '%s\n' "polling JSONP responses must validate callback indexes before response construction." >&2
  exit 1
fi

if ! grep -Fq "try header(Str)" "$DATA" ||
  ! grep -Fq "malformed_frame_returns_empty_list_test" "$DATA" ||
  ! grep -Fq "truncated_frame_returns_empty_list_test" "$DATA" ||
  ! grep -Fq "invalid_json_frame_returns_empty_list_test" "$DATA"; then
  printf '%s\n' "socketio_data must fail closed for malformed frame decode input." >&2
  exit 1
fi

demo_port_count=$(grep -Fc "{http_port, 7878}" "$DEMO" || true)
if [ "$demo_port_count" -ne 1 ]; then
  printf '%s\n' "demo/demo.erl must start the 7878 listener exactly once." >&2
  exit 1
fi

if ! grep -Fq "branch = 06" "$ROOT_DIR/.gitmodules"; then
  printf '%s\n' "Socket.IO client submodule must remain pinned to the legacy 06 branch." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CHECK_PLAN"; then
  printf '%s\n' "Check wrapper plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$HEARTBEAT_PLAN"; then
  printf '%s\n' "Websocket heartbeat timer plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CREDENTIAL_PLAN"; then
  printf '%s\n' "Demo credential boundary plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LONGPOLL_PLAN"; then
  printf '%s\n' "Long-poll timer reference plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$FRAME_DECODE_PLAN"; then
  printf '%s\n' "Malformed frame decode plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$JSONP_PLAN"; then
  printf '%s\n' "JSONP index guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$JSONP_PLAN"; then
  printf '%s\n' "JSONP index guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$FRAME_DECODE_PLAN"; then
  printf '%s\n' "Malformed frame decode plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Run \`scripts/check-baseline.sh\`" "$VISION"; then
  printf '%s\n' "VISION must include the static baseline command in contribution guidance." >&2
  exit 1
fi

if ! grep -Fq "demo/test_certificate.pem" "$VISION" ||
  ! grep -Fq "demo/test_privkey.pem" "$VISION"; then
  printf '%s\n' "VISION must name the only tracked demo certificate/key fixtures." >&2
  exit 1
fi

if command -v erl >/dev/null 2>&1 && command -v escript >/dev/null 2>&1; then
  make -C "$ROOT_DIR" test
else
  printf '%s\n' "Skipping make test: Erlang erl/escript is not installed."
fi

printf '%s\n' "earling-web-sockets maintenance baseline checks passed."
