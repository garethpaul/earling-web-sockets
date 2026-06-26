# earling-web-sockets

WebSocket upgrades authorize Origin headers before creating sessions.
New HTTP transport requests authorize Origin headers before creating sessions.
Returning polling GET requests authorize Origin headers before session lookup or transport dispatch.
Session data POST requests authorize Origin headers before session lookup or transport dispatch.

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/earling-web-sockets` is a maintenance-mode Erlang Socket.IO 0.6 server
implementation with legacy rebar build tooling, browser transport tests, and
local demo pages.

## Repository Contents

- `README.md` - project overview and local usage notes
- `.gitmodules` - legacy Socket.IO client submodule metadata
- `demo` - source or example code
- `Makefile` - local build or utility targets
- `rebar.config` - legacy Erlang dependency/build configuration
- `SECURITY.md` - security reporting and disclosure guidance
- `src` - Erlang Socket.IO server modules
- `test` - EUnit and transport test modules
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: demo, src, test
- Dependency and build manifests: Makefile, rebar.config, .gitmodules
- Entry points or build surfaces: Makefile
- Test-looking files: test/socketio_data_tests.erl, test/socketio_listener_tests.erl, test/socketio_transport_tests.erl

## Getting Started

### Prerequisites

- Git
- Erlang/OTP with `erl` and `escript` on `PATH`
- `make`

### Setup

```bash
git clone https://github.com/garethpaul/earling-web-sockets.git
cd earling-web-sockets
git submodule update --init
make deps
```

The only submodule is `priv/Socket.IO`, using the canonical LearnBoost HTTPS
repository and reviewed Socket.IO `0.6` commit
`7a5197c1e74d1f3a050b330e41e4b6e63afb209c`. The upstream repository no
longer exposes the previously documented `06` branch, so the gitlink is the
dependency identity boundary.

## Running or Using the Project

- Run `make` to fetch legacy rebar dependencies and compile the Erlang app.
- Run `make test` to execute the rebar EUnit path when Erlang/OTP is available.
- The Socket.IO browser client submodule remains pinned to the peeled `0.6`
  tag commit `7a5197c1e74d1f3a050b330e41e4b6e63afb209c` at its canonical HTTPS
  repository and path for protocol compatibility.
- Demo certificates under `demo/test_certificate.pem` and
  `demo/test_privkey.pem` are test-only material for local SSL demos.
- TLS fixture integrity is verified with OpenSSL: the reviewed expired
  certificate fingerprint, encrypted key marker, demo password, and matching
  certificate/key public keys must remain intact. This does not make the
  fixture suitable for production TLS.
- Origin values must be complete `http` or `https` origins without userinfo,
  paths, queries, fragments, trailing parser data, or invalid ports before
  transport handlers apply the configured allow-list. Omitted ports normalize
  to 80 for HTTP and 443 for HTTPS, and DNS hostnames compare
  case-insensitively. Ambiguous duplicate or comma-joined Origin headers fail closed
  before CORS response headers are emitted; empty and non-list values also fail.
  Origin field names are matched case-insensitively across legacy atom, string,
  and binary representations, and duplicates across representations fail closed.
  Polling, XHR multipart, and HTMLFile POST bodies are parsed and decoded only after this
  authorization succeeds.
- Sessions retain the canonical Origin identity that created them. Returning
  polling requests and POST data must present the same identity before session
  lookup or dispatch, even when another Origin is independently allow-listed.
- Session IDs must be canonical lowercase RFC 4122 UUIDv4 values before ETS
  lookup. Invalid or oversized path values are rejected without probing the
  session table.
- Transport POSTs require one valid decimal `Content-Length` no larger than
  1 MiB. Duplicate/malformed lengths and transfer encodings are rejected before
  `parse_post/1`; JSONP callback indexes are validated before session creation.
- Malformed Socket.IO frames decode to an empty message list instead of
  crashing transport handlers.
- Socket.IO frame bodies larger than 1 MiB are rejected during decode before
  body splitting.
- Frame length prefixes are digit-bounded before integer parsing so hostile
  length fields fail closed during decode.
- Long-polling heartbeat and polling timeout handlers ignore stale timer
  references after timers are reset.
- Polling JSONP callback indexes must be bounded non-empty digit strings before
  the JavaScript response wrapper is built.

## Testing and Verification

Run the repository baseline gate:

```bash
make check
make lint
make security-test
scripts/check-baseline.sh
```

`make check` runs the baseline and dependency-free Erlang security tests, and
`make lint` is an alias for the static baseline. `make security-test` compiles
the request-boundary module and runs its EUnit suite without fetching the
legacy dependency graph. When Erlang/OTP is installed, the non-static baseline
also attempts `make test`; the bundled 2012 rebar archive cannot load on
Erlang/OTP 29 and requires an older compatible OTP environment for the
historical full compile/EUnit path. Without `erl`/`escript`, use
`EARLING_STATIC_ONLY=1 make verify` for the static guard checks.
Make targets resolve repository tools from the loaded Makefile, so an absolute
Makefile path can be used from another working directory.
Repository verification requires this Makefile alone. Additional `-f` files,
preloaded Makefiles, caller `MAKEFLAGS`, and non-executing or error-ignoring
modes fail closed before any checker, rebar, or Erlang command runs.
GitHub Actions runs the static portion of `make check` through
`.github/workflows/check.yml` on pushes, pull requests, and manual dispatches.
The workflow pins checkout by commit on Ubuntu 24.04, disables checkout
credential persistence, grants read-only repository access, and uses
`EARLING_STATIC_ONLY=1` with a five-minute timeout. It installs Erlang only for
the standalone security EUnit suite; it does not claim the bundled rebar
archive or complete legacy dependency graph is OTP 29 compatible.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- The SSL demo certificate and private key are checked in for local testing
  only.
- The only tracked certificate/key files are `demo/test_certificate.pem` and
  `demo/test_privkey.pem`; both are test-only local demo fixtures.
- Do not commit production certificates, private keys, tokens, or local rebar
  dependency caches.
- Build outputs such as `ebin`, `.eunit`, `deps`, logs, and the populated
  `priv/Socket.IO` submodule checkout should stay untracked.

## Security and Privacy Notes

- Review changes touching socket routing, origin checks, long-polling request
  handling, SSL options, demo certificates, and dependency fetching.
- The default listener origin configuration in the legacy supervisor allows
  broad origins unless callers provide a narrower `origins` option.
- Origin checks accept only complete HTTP/HTTPS origins, reject userinfo and
  extra URI components, validate explicit ports, and apply scheme-correct
  defaults before the configured allow-list. Parsed and configured DNS
  hostnames compare case-insensitively while near-miss names remain distinct.
  Ambiguous duplicate or comma-joined Origin headers are rejected instead of
  selecting the first value.
- Malformed Socket.IO frame input fails closed during decode.
- Socket.IO frame bodies are capped at 1 MiB before payload splitting.
- Frame length prefixes are digit-bounded before integer parsing.
- Polling JSONP callback indexes are validated and length-bounded before
  session creation and response construction.
- Session lookup and dispatch require the canonical request Origin to match the
  session creator's identity.
- Session IDs, POST lengths, and transfer encodings are bounded before ETS or
  body-parser work.
- This code targets old Socket.IO clients. Do not present it as a modern
  production Socket.IO server without a protocol and security review.

## Maintenance Notes

- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-earling-web-sockets-maintenance-baseline.md` for
  the current maintenance baseline.
- See `docs/plans/2026-06-09-earling-demo-credential-boundary.md` for the
  tracked demo SSL fixture boundary.
- See `docs/plans/2026-06-09-earling-longpoll-timer-refs.md` for the
  long-polling timer reference guard.
- See `docs/plans/2026-06-09-earling-jsonp-index-guard.md` for the polling
  JSONP callback index guard.
- See `docs/plans/2026-06-09-earling-jsonp-index-length-guard.md` for the
  polling JSONP callback index length guard.
- See `docs/plans/2026-06-09-earling-malformed-frame-decode.md` for malformed
  frame decode handling.
- See `docs/plans/2026-06-09-earling-frame-length-guard.md` for the Socket.IO
  frame body length guard.
- See `docs/plans/2026-06-09-earling-frame-length-prefix-guard.md` for the
  Socket.IO frame length prefix guard.
- See `docs/plans/2026-06-10-ci-baseline.md` for the GitHub Actions baseline.
- See `docs/plans/2026-06-10-web-origin-boundary.md` for canonical web-origin
  parsing and default-port handling.
- See `docs/plans/2026-06-12-origin-host-case-normalization.md` for
  case-insensitive DNS hostname matching in origin allow-lists.
- See `docs/plans/2026-06-13-origin-header-cardinality.md` for duplicate and
  comma-joined Origin header rejection.
- See `docs/plans/2026-06-13-polling-authorization-order.md` for polling POST
  authorization ordering.
- See `docs/plans/2026-06-14-xhr-multipart-authorization-order.md` for XHR
  multipart POST authorization ordering.
- See `docs/plans/2026-06-14-htmlfile-authorization-order.md` for HTMLFile POST
  authorization ordering.
- Use [`RUNTIME_VERIFICATION.md`](RUNTIME_VERIFICATION.md) for exact-head
  Erlang/OTP, compile, EUnit, transport-client, timer, HTTP demo, and SSL demo
  evidence. It requires synthetic origins and payloads plus sanitized results.

## Contributing

Keep changes small and tied to the project that is already present in this
repository. For Erlang changes, document the Erlang/OTP version used, run
`make test` when `escript` is available, run `scripts/check-baseline.sh`, avoid
committing generated dependency directories or local configuration, and update
this README when setup or verification steps change.
