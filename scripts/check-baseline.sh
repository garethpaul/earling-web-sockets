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
FRAME_LENGTH_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-frame-length-guard.md"
FRAME_LENGTH_PREFIX_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-frame-length-prefix-guard.md"
JSONP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-jsonp-index-guard.md"
JSONP_LENGTH_PLAN="$ROOT_DIR/docs/plans/2026-06-09-earling-jsonp-index-length-guard.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
ORIGIN_PLAN="$ROOT_DIR/docs/plans/2026-06-10-web-origin-boundary.md"
ORIGIN_CASE_PLAN="$ROOT_DIR/docs/plans/2026-06-12-origin-host-case-normalization.md"
ORIGIN_HEADER_PLAN="$ROOT_DIR/docs/plans/2026-06-13-origin-header-cardinality.md"
SUBMODULE_PLAN="$ROOT_DIR/docs/plans/2026-06-13-socketio-submodule-identity.md"
POLLING_AUTH_PLAN="$ROOT_DIR/docs/plans/2026-06-13-polling-authorization-order.md"
POLLING_AUTH_CHECK="$ROOT_DIR/scripts/check-polling-authorization-order.py"
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
  ".github/workflows/check.yml" \
  "docs/plans/2026-06-09-earling-demo-credential-boundary.md" \
  "docs/plans/2026-06-09-earling-jsonp-index-guard.md" \
  "docs/plans/2026-06-09-earling-jsonp-index-length-guard.md" \
  "docs/plans/2026-06-09-earling-longpoll-timer-refs.md" \
  "docs/plans/2026-06-09-earling-malformed-frame-decode.md" \
  "docs/plans/2026-06-09-earling-frame-length-guard.md" \
  "docs/plans/2026-06-09-earling-frame-length-prefix-guard.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-10-web-origin-boundary.md" \
  "docs/plans/2026-06-12-origin-host-case-normalization.md" \
  "docs/plans/2026-06-13-origin-header-cardinality.md" \
  "docs/plans/2026-06-13-socketio-submodule-identity.md" \
  "docs/plans/2026-06-13-polling-authorization-order.md" \
  "scripts/check-polling-authorization-order.py" \
  "docs/plans/2026-06-08-earling-check-wrapper.md" \
  "docs/plans/2026-06-08-earling-websocket-heartbeat-timers.md" \
  "docs/plans/2026-06-08-earling-web-sockets-maintenance-baseline.md"; do
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
done

python3 "$POLLING_AUTH_CHECK" "$POLLING"

if ! grep -Fq "Erlang/OTP" "$README" ||
  ! grep -Fq "escript" "$README" ||
  ! grep -Fq "make check" "$README" ||
  ! grep -Fq "make test" "$README" ||
  ! grep -Fq "Socket.IO 0.6" "$README" ||
  ! grep -Fq "test-only" "$README" ||
  ! grep -Fq "Malformed Socket.IO frames" "$README" ||
  ! grep -Fq "GitHub Actions" "$README" ||
  ! grep -Fq 'Origin values must be complete `http` or `https` origins' "$README"; then
  printf '%s\n' "README must document Erlang, escript, tests, legacy Socket.IO scope, demo certificate status, frame decode, GitHub Actions, and Origin handling." >&2
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
  ! grep -Fq "lint: verify" "$MAKEFILE" ||
  ! grep -Fq "check: verify" "$MAKEFILE"; then
  printf '%s\n' "Makefile must preflight Erlang erl/escript before rebar targets and expose make lint/check." >&2
  exit 1
fi

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW" ||
  ! grep -Fq "run: EARLING_STATIC_ONLY=1 make check" "$CI_WORKFLOW" ||
  ! grep -Fq "permissions:" "$CI_WORKFLOW" ||
  ! grep -Fq "contents: read" "$CI_WORKFLOW" ||
  ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" ||
  ! grep -Fq "cancel-in-progress: true" "$CI_WORKFLOW" ||
  ! grep -Fq "timeout-minutes: 5" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must pin checkout and run the bounded, read-only make check baseline." >&2
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

for origin_contract in \
  "userinfo = undefined" \
  "path = []" \
  "fragment = undefined" \
  '}, ""}' \
  "origin_port(Scheme, Port)" \
  '{"http", undefined} -> 80' \
  '{"https", undefined} -> 443' \
  "Value =< 65535" \
  "https_port_default_origins_test" \
  "non_web_scheme_rejected_test" \
  "userinfo_origin_rejected_test" \
  "path_origin_rejected_test" \
  "trailing_origin_data_rejected_test" \
  "invalid_origin_port_rejected_test"; do
  if ! grep -Fq "$origin_contract" "$LISTENER" "$LISTENER_TESTS"; then
    printf '%s\n' "Canonical web-origin contract is missing: $origin_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "Status: Completed" "$ORIGIN_PLAN" ||
  ! grep -Fq "make check" "$ORIGIN_PLAN"; then
  printf '%s\n' "Web-origin boundary plan must remain completed with verification recorded." >&2
  exit 1
fi

for origin_case_contract in \
  "origin_host_matches(Host, AllowedHost)" \
  "string:to_lower(Host) =:= string:to_lower(AllowedHost)" \
  "origin_port_matches(Port, AllowedPort)" \
  "verify_origin_1(Origin, [_Invalid|Rest])" \
  "mixed_case_request_host_allowed_test" \
  "mixed_case_configured_host_allowed_test" \
  "mixed_case_near_miss_host_rejected_test" \
  "malformed_configured_origin_rejected_test" \
  "malformed_configured_entry_is_skipped_test"; do
  if ! grep -Fq "$origin_case_contract" "$LISTENER" "$LISTENER_TESTS"; then
    printf '%s\n' "Case-insensitive origin-host contract is missing: $origin_case_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "Status: Completed" "$ORIGIN_CASE_PLAN" ||
  ! grep -Fq "19 listener tests pass" "$ORIGIN_CASE_PLAN"; then
  printf '%s\n' "Origin host case-normalization plan must remain completed and runtime verified." >&2
  exit 1
fi

if ! grep -Fq "case-insensitively" "$README" ||
  ! grep -Fq "case-insensitively" "$SECURITY"; then
  printf '%s\n' "README and SECURITY must document case-insensitive origin hosts." >&2
  exit 1
fi

for origin_header_contract in \
  "verify_origin_headers(Headers, Origins)" \
  "proplists:get_all_values('Origin', Headers)" \
  'lists:member($,, Origin)' \
  "missing_origin_header_is_absent_test" \
  "single_origin_header_is_verified_test" \
  "duplicate_origin_headers_are_rejected_test" \
  "comma_joined_origin_header_is_rejected_test" \
  "empty_origin_header_is_rejected_test" \
  "non_list_origin_header_is_rejected_test"; do
  if ! grep -Fq "$origin_header_contract" "$LISTENER" "$LISTENER_TESTS"; then
    printf '%s\n' "Origin header cardinality contract is missing: $origin_header_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc 'socketio_listener:verify_origin_headers' "$POLLING")" -ne 1 ] ||
  [ "$(grep -Fc 'socketio_listener:verify_origin_headers' "$XHR_MULTIPART")" -ne 1 ] ||
  grep -Fq "proplists:get_value('Origin', Headers)" "$POLLING" "$XHR_MULTIPART"; then
  printf '%s\n' "CORS transports must use the shared Origin header verifier exactly once." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ORIGIN_HEADER_PLAN" ||
  ! grep -Fq "EUnit was not executed" "$ORIGIN_HEADER_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$ORIGIN_HEADER_PLAN"; then
  printf '%s\n' "Origin header cardinality plan must record truthful completed verification." >&2
  exit 1
fi

if ! grep -Fq "comma-joined Origin headers fail closed" "$README" ||
  ! grep -Fq "comma-joined" "$SECURITY" ||
  ! grep -Fq "comma-joined Origin headers fail closed" "$VISION" ||
  ! grep -Fq "Origin header verification must reject" "$ROOT_DIR/AGENTS.md" ||
  ! grep -Fq "Reject duplicate, empty, non-list, and comma-joined Origin headers" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project guidance must document ambiguous Origin header rejection." >&2
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

if ! grep -Fq "MAX_JSONP_INDEX_LENGTH" "$POLLING" ||
  ! grep -Fq "length(Index) =< ?MAX_JSONP_INDEX_LENGTH" "$POLLING" ||
  ! grep -Fq "jsonp_index_rejects_overlong_values_test" "$POLLING"; then
  printf '%s\n' "polling JSONP callback indexes must be length-bounded before response construction." >&2
  exit 1
fi

if ! grep -Fq "bounded non-empty digit strings" "$README" ||
  ! grep -Fq "validated and length-bounded" "$README" ||
  ! grep -Fq "bounded non-empty digit" "$SECURITY" ||
  ! grep -Fq "bounded non-empty digit" "$VISION"; then
  printf '%s\n' "Docs must describe the bounded JSONP callback index guard." >&2
  exit 1
fi

if ! grep -Fq "try header(Str)" "$DATA" ||
  ! grep -Fq "malformed_frame_returns_empty_list_test" "$DATA" ||
  ! grep -Fq "truncated_frame_returns_empty_list_test" "$DATA" ||
  ! grep -Fq "invalid_json_frame_returns_empty_list_test" "$DATA"; then
  printf '%s\n' "socketio_data must fail closed for malformed frame decode input." >&2
  exit 1
fi

if ! grep -Fq "MAX_FRAME_LENGTH" "$DATA" ||
  ! grep -Fq "Length > ?MAX_FRAME_LENGTH" "$DATA" ||
  ! grep -Fq "oversized_frame_returns_empty_list_test" "$DATA"; then
  printf '%s\n' "socketio_data must reject oversized declared frame lengths before body splitting." >&2
  exit 1
fi

if ! grep -Fq "MAX_FRAME_LENGTH_DIGITS" "$DATA" ||
  ! grep -Fq "length(Acc) < ?MAX_FRAME_LENGTH_DIGITS" "$DATA" ||
  ! grep -Fq "safe_frame_length(Acc)" "$DATA" ||
  ! grep -Fq "overlong_frame_length_prefix_returns_empty_list_test" "$DATA"; then
  printf '%s\n' "socketio_data must bound frame length prefixes before integer parsing." >&2
  exit 1
fi

if ! grep -Fq "Socket.IO frame bodies larger than 1 MiB" "$README" ||
  ! grep -Fq "frame bodies are capped at 1 MiB" "$SECURITY" ||
  ! grep -Fq "frame bodies are capped at 1 MiB" "$VISION"; then
  printf '%s\n' "Docs must describe the Socket.IO frame body length guard." >&2
  exit 1
fi

if ! grep -Fq "Frame length prefixes are digit-bounded" "$README" ||
  ! grep -Fq "frame length prefixes are digit-bounded" "$SECURITY" ||
  ! grep -Fq "Frame length prefixes are digit-bounded" "$VISION"; then
  printf '%s\n' "Docs must describe the Socket.IO frame length prefix guard." >&2
  exit 1
fi

demo_port_count=$(grep -Fc "{http_port, 7878}" "$DEMO" || true)
if [ "$demo_port_count" -ne 1 ]; then
  printf '%s\n' "demo/demo.erl must start the 7878 listener exactly once." >&2
  exit 1
fi

python3 - "$ROOT_DIR/.gitmodules" <<'PY'
import configparser
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
config = configparser.ConfigParser(interpolation=None)
config.read(path)
expected_section = 'submodule "priv/Socket.IO"'
if config.sections() != [expected_section]:
    raise SystemExit("Exactly one canonical Socket.IO submodule section is required.")
expected = {
    "path": "priv/Socket.IO",
    "url": "https://github.com/LearnBoost/socket.io-client.git",
    "branch": "06",
}
if dict(config[expected_section]) != expected:
    raise SystemExit("Socket.IO submodule path, HTTPS URL, and branch must remain canonical.")
PY

if ! grep -Fq "status: completed" "$SUBMODULE_PLAN" ||
  ! grep -Fq "EARLING_STATIC_ONLY=1 make check" "$SUBMODULE_PLAN" ||
  ! grep -Fq "source from HTTPS to HTTP failed" "$SUBMODULE_PLAN" ||
  ! grep -Fq 'unreviewed `update` option failed' "$SUBMODULE_PLAN"; then
  printf '%s\n' "Socket.IO submodule identity plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$POLLING_AUTH_PLAN" ||
  ! grep -Fq "EARLING_STATIC_ONLY=1 make check" "$POLLING_AUTH_PLAN" ||
  ! grep -Fq "hostile source mutations were rejected" "$POLLING_AUTH_PLAN"; then
  printf '%s\n' "Polling authorization-order plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "only submodule" "$README" ||
  ! grep -Fq "exactly one submodule" "$SECURITY" ||
  ! grep -Fq "only submodule" "$VISION"; then
  printf '%s\n' "Project guidance must document the canonical submodule identity." >&2
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

if ! grep -Fq "status: completed" "$FRAME_LENGTH_PLAN"; then
  printf '%s\n' "Frame length guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$FRAME_LENGTH_PLAN"; then
  printf '%s\n' "Frame length guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$FRAME_LENGTH_PREFIX_PLAN"; then
  printf '%s\n' "Frame length prefix guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$FRAME_LENGTH_PREFIX_PLAN"; then
  printf '%s\n' "Frame length prefix guard plan must record make check verification." >&2
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

if ! grep -Fq "status: completed" "$JSONP_LENGTH_PLAN"; then
  printf '%s\n' "JSONP index length guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$JSONP_LENGTH_PLAN"; then
  printf '%s\n' "JSONP index length guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN"; then
  printf '%s\n' "Earling CI baseline plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "Earling CI baseline plan must record make check verification." >&2
  exit 1
fi

for workflow_contract in \
  "runs-on: ubuntu-24.04" \
  "permissions:" \
  "contents: read" \
  "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  "persist-credentials: false" \
  "timeout-minutes: 5" \
  "EARLING_STATIC_ONLY=1 make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "Earling CI workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print | LC_ALL=C sort)
if [ "$workflow_paths" != "$CI_WORKFLOW" ]; then
  printf '%s\n' "The canonical Earling check must be the only GitHub Actions workflow." >&2
  exit 1
fi

if [ "$(grep -Fc "actions/checkout@" "$CI_WORKFLOW")" -ne 1 ] ||
  [ "$(grep -Fc "persist-credentials:" "$CI_WORKFLOW")" -ne 1 ] ||
  grep -Fq "persist-credentials: true" "$CI_WORKFLOW"; then
  printf '%s\n' "Earling CI must use one pinned checkout with credential persistence disabled." >&2
  exit 1
fi

if [ "$(grep -Ec '^[[:space:]]*permissions:' "$CI_WORKFLOW")" -ne 1 ] ||
  grep -Eq 'write-all|contents:[[:space:]]*write|pull-requests:[[:space:]]*write|actions:[[:space:]]*write' "$CI_WORKFLOW"; then
  printf '%s\n' "Earling CI permissions must remain globally read-only." >&2
  exit 1
fi

if grep -Fq "ubuntu-latest" "$CI_WORKFLOW"; then
  printf '%s\n' "Earling CI must not use a floating Ubuntu runner." >&2
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

if [ "${EARLING_STATIC_ONLY:-0}" = "1" ]; then
  printf '%s\n' "Skipping make test: static-only verification requested."
elif command -v erl >/dev/null 2>&1 && command -v escript >/dev/null 2>&1; then
  make -C "$ROOT_DIR" test
else
  printf '%s\n' "Skipping make test: Erlang erl/escript is not installed."
fi

printf '%s\n' "earling-web-sockets maintenance baseline checks passed."
