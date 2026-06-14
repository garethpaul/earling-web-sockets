## Earling Web Sockets Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Earling Web Sockets is an Erlang Socket.IO server implementation sample based on
the socket.io-erlang codebase.

The repository is useful as a preserved Socket.IO 0.6-era Erlang implementation
with demos, transports, tests, and rebar build files. Project details live in
[`README.md`](README.md).

The goal is to keep the maintenance-mode server understandable and buildable
without pretending it tracks modern Socket.IO protocol changes.

The current focus is:

Priority:

- Preserve compatibility expectations for the old Socket.IO protocol family
- Keep Erlang crypto/SSL build prerequisites documented
- Maintain demo and test coverage around transports
- Avoid broad protocol rewrites without a compatibility plan

Current baseline:

- The legacy browser client is the only submodule and remains fixed to its
  canonical `priv/Socket.IO` path, LearnBoost HTTPS URL, and `06` branch.
- `make deps`, `make`, and `make test` now verify `erl` and `escript` before
  invoking legacy `rebar`.
- Keep location-independent Make targets rooted to the loaded repository
  Makefile for checker and bundled rebar invocation.
- `scripts/check-baseline.sh` runs full rebar tests when Erlang/OTP is
  available and static maintenance checks otherwise.
- Malformed or relative Origin values fail closed instead of crashing listener
  origin checks.
- Origin parsing requires complete HTTP/HTTPS origins without userinfo or extra
  URI components and normalizes omitted ports by scheme before allow-list
  matching.
- Origin allow-list hostnames compare case-insensitively while preserving exact
  hostname boundaries and explicit wildcard behavior.
- Duplicate, empty, non-list, and comma-joined Origin headers fail closed before
  polling or XHR-multipart transports emit CORS response headers.
- Polling POST bodies are parsed and decoded only after Origin authorization.
- XHR multipart POST bodies reject disallowed origins before parsing or decode.
- HTMLFile POST bodies reject disallowed origins before parsing or decode.
- Malformed Socket.IO frame input fails closed instead of crashing transport
  decode paths.
- Socket.IO frame bodies are capped at 1 MiB before payload splitting.
- Frame length prefixes are digit-bounded before integer parsing.
- The non-SSL demo starts each listener port once so local demo behavior stays
  predictable.
- Demo SSL fixtures are limited to `demo/test_certificate.pem` and
  `demo/test_privkey.pem`, and both are documented as test-only local demo
  material.
- Long-polling transports ignore stale heartbeat and polling timer references
  after timers are reset.
- Polling JSONP callback indexes are restricted to bounded non-empty digit
  strings before JavaScript response construction.
- GitHub Actions runs the static maintenance `make check` baseline with pinned,
  read-only workflow dependencies before review.

Next priorities:

- Add clear maintenance-status and supported-client notes
- Verify the rebar build and tests on a documented Erlang version
- Bound synchronous transport calls made by the central HTTP router
- Document SSL demo certificate usage
- Tighten contribution and known-issues sections that the README lists as TODOs

Contribution rules:

- One PR = one focused transport, build, test, or documentation change.
- Run `scripts/check-baseline.sh` before pushing Erlang or build changes.
- Preserve old protocol compatibility unless a migration note explains the break.
- Keep `.github/workflows/check.yml` aligned with the static maintenance
  baseline until a compatible Erlang/OTP release is documented and tested.
- Keep demo certificates clearly marked as test-only, and do not add tracked
  certificate/key files beyond the two demo fixtures.

## Security

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Socket servers and SSL demos need clear boundaries. Test certificates must not
be used as production credentials, and server changes should avoid unsafe
defaults for real deployments.

## What We Will Not Merge (For Now)

- Modern Socket.IO rewrites without a protocol compatibility plan
- Production credential material
- SSL or transport changes without test/demo verification
- Changes that remove maintenance-mode context from the README

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
