# Changes

## 2026-06-13

- Rooted Make targets to the loaded Makefile so the checker and bundled rebar
  resolve correctly from external working directories.
- Reject duplicate, empty, non-list, and comma-joined Origin headers before
  polling or XHR-multipart transports emit CORS response headers.
- Route both CORS transport paths through one listener-owned header verifier.
- Replaced the loose Socket.IO submodule branch check with a structured,
  fail-closed identity contract for its section, path, HTTPS URL, and branch.
- Reject extra submodules and unreviewed submodule options in the static gate.

## 2026-06-12

- Compare parsed and configured origin DNS hostnames case-insensitively while
  preserving exact host boundaries, wildcard behavior, and port matching.
- Fail closed for malformed configured origin host or port values.
- Add EUnit and static baseline regressions for mixed-case and near-miss hosts.

## 2026-06-10

- Restricted origin allow-list evaluation to fully consumed HTTP/HTTPS origins
  without userinfo, paths, queries, fragments, or invalid explicit ports.
- Normalized omitted origin ports to 80 for HTTP and 443 for HTTPS.
- Added EUnit and static baseline coverage for malformed origin variants and
  secure default-port handling.
- Pinned hosted static verification to Ubuntu 24.04, disabled checkout
  credential persistence, and added fail-closed workflow trust-boundary checks.
- Added a GitHub Actions check workflow that runs the existing maintenance
  `make check` baseline on pushes, pull requests, and manual dispatches.
- Pinned checkout by commit, restricted workflow permissions to read-only,
  enabled stale-run cancellation, and bounded the static job to five minutes.
- Documented that hosted verification is static until a compatible Erlang/OTP
  release is established for the bundled legacy rebar toolchain.
- Added explicit `EARLING_STATIC_ONLY=1` handling so runner image changes cannot
  silently enable tests against an unqualified Erlang release.
- Added a static guard requiring the CI workflow and completed CI baseline plan
  to remain checked in.

## 2026-06-09

- Bounded Socket.IO frame length prefixes before integer parsing during decode.
- Rejected oversized declared Socket.IO frame body lengths before payload
  splitting.
- Exposed `make lint` as an alias for the static maintenance baseline.
- Bounded polling JSONP callback index lengths before response construction.
- Restricted polling JSONP callback indexes to non-empty digit strings before
  constructing JavaScript responses.
- Made malformed Socket.IO frame decode fail closed to an empty message list.
- Ignored stale heartbeat and polling timeout references in long-polling
  transports after timers are reset.
- Added a baseline guard that rejects tracked certificate/key material outside
  the two test-only SSL demo fixtures.
- Documented the demo credential boundary in the README, vision, security
  policy, and maintenance plan.

## 2026-06-08

- Added a root `make check` wrapper for the maintenance baseline.
- Ignored stale websocket heartbeat timer messages after the heartbeat timer is
  reset, preventing canceled timer deliveries from sending extra heartbeats.
- Added explicit Erlang/OTP tool checks before legacy `rebar` tasks run.
- Added a baseline script that runs rebar tests when `erl`/`escript` are
  available and static maintenance checks otherwise.
- Rejected malformed, relative, or hostless Origin values instead of letting
  URI parsing crash or wildcard origin rules allow invalid input.
- Removed a duplicate demo listener start.
- Documented maintenance-mode build expectations and test-only demo SSL
  certificates.
