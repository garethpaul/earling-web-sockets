---
title: Earling Web Sockets maintenance baseline
date: 2026-06-08
status: completed
execution: code
---

## Context

This repository is a legacy Erlang Socket.IO server implementation using the
old Socket.IO 0.6 client submodule, a vendored rebar script, EUnit tests, and
demo HTTP/SSL servers. The generated README previously described it as a static
web project and did not tell maintainers how to verify Erlang changes.

Local verification found that Erlang/OTP is not installed in the current
environment: `make test` failed because `/usr/bin/env` could not find
`escript`.

## Goals

- Replace generic README guidance with accurate Erlang Socket.IO maintenance
  notes.
- Document the toolchain, submodule, demo certificate, and test expectations.
- Keep missing Erlang failures explicit before rebar starts.
- Add a static baseline check that remains useful on machines without Erlang.
- Reject malformed, relative, or hostless Origin headers without crashing or
  allowing them through wildcard origin configuration.

## Scope Boundaries

- Do not modernize the Socket.IO protocol implementation in this pass.
- Do not regenerate demo certificates or replace the legacy rebar workflow.
- Do not vendor dependency directories or generated `ebin` outputs.

## Implementation

- `README.md` documents Erlang/OTP, rebar, `git submodule update --init`, the
  Socket.IO 0.6-era compatibility scope, and verification commands.
- `scripts/check-baseline.sh` verifies the maintenance baseline statically and
  runs `make test` only when `erl` and `escript` are available.
- `socketio_listener:verify_origin/2` now fails closed for malformed, relative,
  or hostless Origin values, with listener tests covering invalid and relative
  origins.
- `demo/demo.erl` no longer starts the same listener twice.
- `CHANGES.md` records the baseline.

## Verification

- `scripts/check-baseline.sh`
- `make test` attempted; blocked locally because Erlang `escript` is not
  installed.
- `git diff --check`
