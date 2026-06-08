#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
MAKEFILE="$ROOT_DIR/Makefile"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-earling-web-sockets-maintenance-baseline.md"
LISTENER="$ROOT_DIR/src/socketio_listener.erl"
LISTENER_TESTS="$ROOT_DIR/test/socketio_listener_tests.erl"
DEMO="$ROOT_DIR/demo/demo.erl"

for path in \
  "README.md" \
  "VISION.md" \
  "Makefile" \
  "rebar.config" \
  "src/socketio.app.src" \
  "src/socketio_listener.erl" \
  "demo/demo.erl" \
  "test/socketio_data_tests.erl" \
  "test/socketio_listener_tests.erl" \
  ".gitmodules" \
  "CHANGES.md" \
  "docs/plans/2026-06-08-earling-web-sockets-maintenance-baseline.md"; do
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
done

if ! grep -Fq "Erlang/OTP" "$README" ||
  ! grep -Fq "escript" "$README" ||
  ! grep -Fq "make test" "$README" ||
  ! grep -Fq "Socket.IO 0.6" "$README" ||
  ! grep -Fq "test-only" "$README" ||
  ! grep -Fq "Malformed or relative Origin values" "$README"; then
  printf '%s\n' "README must document Erlang, escript, tests, legacy Socket.IO scope, demo certificate status, and Origin handling." >&2
  exit 1
fi

if grep -Fq "static web project" "$README" ||
  grep -Fq "no obvious test files detected" "$README"; then
  printf '%s\n' "README must not contain stale scanner-generated project classification." >&2
  exit 1
fi

if ! grep -Fq "command -v erl" "$MAKEFILE" ||
  ! grep -Fq "command -v escript" "$MAKEFILE"; then
  printf '%s\n' "Makefile must preflight Erlang erl/escript before rebar targets." >&2
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

if ! grep -Fq "Run \`scripts/check-baseline.sh\`" "$VISION"; then
  printf '%s\n' "VISION must include the static baseline command in contribution guidance." >&2
  exit 1
fi

if command -v erl >/dev/null 2>&1 && command -v escript >/dev/null 2>&1; then
  make -C "$ROOT_DIR" test
else
  printf '%s\n' "Skipping make test: Erlang erl/escript is not installed."
fi

printf '%s\n' "earling-web-sockets maintenance baseline checks passed."
