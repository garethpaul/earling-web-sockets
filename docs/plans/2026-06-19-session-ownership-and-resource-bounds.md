---
title: Session Ownership and Resource Bounds
type: security
status: pending_hosted_verification
date: 2026-06-19
---

# Session Ownership and Resource Bounds

## Findings

- Sessions were keyed only by UUID. Any independently allow-listed Origin that
  learned a session ID could issue returning polling requests or POST data to
  that session.
- Unbounded path-provided session IDs reached ETS lookups, and transport POSTs
  reached the legacy parser without an HTTP body-size boundary.
- New JSONP polling requests allocated a session before validating the callback
  index used to construct JavaScript.
- `.gitmodules` named an upstream `06` branch that does not exist, while the
  repository contained no gitlink for the browser client.
- The TLS mutation test used GNU-only `sed -i`, so the documented local gate
  failed on macOS before completing all fixture mutations.

## Fix

- Store each session's canonical `{scheme, lowercase host, normalized port}`
  Origin identity and require exact identity equality before returning polling
  or POST dispatch.
- Accept only lowercase RFC 4122 UUIDv4 session IDs before ETS access.
- Require one decimal `Content-Length` no larger than 1 MiB and reject transfer
  encodings before calling `parse_post/1`.
- Validate bounded decimal JSONP indexes before creating a session.
- Pin `priv/Socket.IO` to the peeled upstream `0.6` tag commit
  `7a5197c1e74d1f3a050b330e41e4b6e63afb209c` and verify the staged gitlink.
- Replace in-place sed edits with portable temporary-file rewrites.

## RED Evidence

- Sixteen focused EUnit cases failed with `undef` before the request-security
  owner module existed.
- The hostile structural checker failed for every missing ownership, ordering,
  hosted-test, portability, and gitlink contract.
- The existing TLS mutation suite failed on BSD sed.

## Local GREEN Evidence

- `make security-test`: 16 tests passed on Erlang/OTP 29.0.2.
- Direct `erlc` compilation passed for `socketio_request_security.erl`,
  `socketio_http.erl`, and `socketio_http_misultin.erl`; only the pre-existing
  undefined external behaviour warning remained for the last module.
- `python3 tests/check-security-boundaries.py` passed.
- `sh tests/check-demo-tls-fixture.sh` passed all fixture mutations on macOS.
- `EARLING_STATIC_ONLY=1 make verify` passed from the repository root.
- Nine hostile mutations were rejected: Origin ownership, POST size, UUID
  version, JSONP length, stored session Origin, WebSocket Origin threading,
  hosted EUnit execution, TLS test portability, and the exact submodule gitlink.

## Legacy Runtime Limit

The checked-in 2012 rebar escript contains BEAM bytecode that Erlang/OTP 29
refuses to load. `make deps`, `make compile`, and the historical full EUnit
suite therefore require a compatible older OTP environment and remain unrun.
This is separate from the dependency-free security EUnit suite, which runs on
OTP 29 and in the hosted workflow.

## Hosted Evidence

Exact-head GitHub Actions and CodeQL checks remain pending.
