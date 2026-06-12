# earling-web-sockets

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

The `priv/Socket.IO` submodule is intentionally pinned to the legacy
Socket.IO 0.6 client branch used by the demos.

## Running or Using the Project

- Run `make` to fetch legacy rebar dependencies and compile the Erlang app.
- Run `make test` to execute the rebar EUnit path when Erlang/OTP is available.
- The Socket.IO browser client submodule remains pinned to the legacy `06`
  branch for protocol compatibility.
- Demo certificates under `demo/test_certificate.pem` and
  `demo/test_privkey.pem` are test-only material for local SSL demos.
- Origin values must be complete `http` or `https` origins without userinfo,
  paths, queries, fragments, trailing parser data, or invalid ports before
  transport handlers apply the configured allow-list. Omitted ports normalize
  to 80 for HTTP and 443 for HTTPS, and DNS hostnames compare
  case-insensitively.
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
scripts/check-baseline.sh
```

`make check` runs the baseline gate, and `make lint` is an alias for the same
static baseline. When Erlang/OTP is installed, the baseline gate runs
`make test`. In documentation-only environments without `erl`/`escript`, it
performs static guard checks and reports that the rebar tests were skipped.
GitHub Actions runs the static portion of `make check` through
`.github/workflows/check.yml` on pushes, pull requests, and manual dispatches.
The workflow pins checkout by commit on Ubuntu 24.04, disables checkout
credential persistence, grants read-only repository access, and uses
`EARLING_STATIC_ONLY=1` with a five-minute timeout so runner image changes
cannot silently select an unqualified Erlang release. It does not claim Erlang
runtime compatibility; full rebar tests still require a locally installed,
compatible Erlang/OTP.

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
- Malformed Socket.IO frame input fails closed during decode.
- Socket.IO frame bodies are capped at 1 MiB before payload splitting.
- Frame length prefixes are digit-bounded before integer parsing.
- Polling JSONP callback indexes are validated and length-bounded before
  response construction.
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

## Contributing

Keep changes small and tied to the project that is already present in this
repository. For Erlang changes, document the Erlang/OTP version used, run
`make test` when `escript` is available, run `scripts/check-baseline.sh`, avoid
committing generated dependency directories or local configuration, and update
this README when setup or verification steps change.
