---
title: Earling Long-Poll Timer References
date: 2026-06-09
status: completed
execution: code
---

## Context

The websocket transport already ignores stale heartbeat timer references after
resetting the timer. The long-polling transports still accepted any heartbeat
or polling timeout while connected, so canceled timer deliveries could trigger
extra heartbeats or premature polling responses.

## Goals

- Match timeout messages against the current timer reference before sending
  long-polling heartbeats or polling keepalive responses.
- Ignore stale connected heartbeat timers for `xhr-multipart` and `htmlfile`.
- Ignore stale connected polling duration timers for polling transports.
- Preserve the guard with source-level EUnit tests and the static baseline.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Erlang/OTP was not installed in this environment, so the local verification path
used the repository's static baseline checks.
