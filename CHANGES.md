# Changes

## 2026-06-26 14:03:01 PDT - P1 - Make repository verification authoritative

### Summary

Closed a false-green verification boundary where a later `-f` Makefile could
replace every public leaf recipe, or GNU Make execution modes could suppress or
ignore the repository-owned security commands.

### Work completed

- Converted public targets to guarded double-colon rules with a repository
  authority prerequisite.
- Rejected later single-colon replacement, later double-colon append,
  preloaded Makefiles, caller invocation variables, and ten non-executing or
  error-ignoring modes.
- Rooted commands to the first reviewed Makefile instead of the last loaded
  file and preserved external-directory execution.
- Added three executable Make authority regressions to `make verify`.
- Extended the shell baseline and repository guidance with the reviewed
  invocation contract.

### Threads

- None; the focused Make authority work was completed directly.

### Files changed

- `Makefile` — own public target execution and reject unsafe invocation modes.
- `tests/test-makefile-root.py` — cover replacement, append, mode, and caller
  variable attacks.
- `scripts/check-baseline.sh` — freeze the Make authority implementation,
  regressions, plan evidence, and guidance.
- `README.md`, `SECURITY.md`, `VISION.md`, `AGENTS.md`, and
  `docs/plans/2026-06-26-make-invocation-authority.md` — document behavior and
  completed evidence.

### Validation

- Full static baseline, executable security boundary checks, Make authority
  suite, external-directory gate, and repository hygiene audits — recorded in
  the completed plan.

### Bugs / findings

- Fixed P1 false-green verification through later Makefile recipe replacement.
- Fixed P1 false-green verification through dry-run, touch, question, and
  ignore-error modes.
- Socket.IO protocol, transport, Origin authorization, session ownership,
  request limits, dependency, submodule, and demo TLS behavior did not change.

### Blockers

- The bundled 2012 rebar archive remains incompatible with Erlang/OTP 29; this
  verification-only change does not broaden legacy runtime claims.
- Codex review authentication is unavailable in this environment; attempt it
  once after the pull request is open, then rely on local and hosted gates.

### Next action

- Merge only the exact hosted-green pull-request head, then continue repository
  triage.

## 2026-06-19

- Bound each Socket.IO session to the canonical Origin identity that created
  it so a different allow-listed Origin cannot reuse a known session ID.
- Rejected non-canonical UUIDv4 session IDs before ETS lookup and validated
  JSONP callback indexes before allocating sessions.
- Required a single decimal transport POST Content-Length capped at 1 MiB and
  rejected transfer encodings before legacy body parsing.
- Replaced the nonexistent mutable `06` submodule branch claim with the exact
  peeled Socket.IO `0.6` gitlink
  `7a5197c1e74d1f3a050b330e41e4b6e63afb209c`.
- Added dependency-free Erlang security EUnit tests and documented that the
  bundled 2012 rebar archive cannot load on Erlang/OTP 29.
- Made the OpenSSL TLS fixture mutation suite portable across BSD and GNU sed.

## 2026-06-17

- Added OpenSSL-backed integrity checks for the encrypted demo TLS fixture pair,
  including reviewed identity, expiry, password, and public-key matching.

## 2026-06-15

- Session data POST requests authorize Origin headers before session lookup or transport dispatch.
- Matched Origin header names case-insensitively across legacy parser representations.
- Returning polling GET requests authorize Origin headers before session lookup or transport dispatch.

## 2026-06-14

- Added an exact-head Earling legacy runtime verification matrix that separates
  static checks from sanitized compile, EUnit, transport-client, timer, HTTP,
  and SSL demo evidence.
- New HTTP transport requests authorize Origin headers before creating sessions.
- WebSocket upgrades authorize Origin headers before creating sessions.
- Reject disallowed HTMLFile POST origins before parsing form data or decoding
  Socket.IO frames.
- Reject disallowed XHR multipart POST origins before parsing form data or
  decoding Socket.IO frames.

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
