---
title: Earling Websocket Heartbeat Timers
date: 2026-06-08
status: completed
execution: code
---

## Context

`socketio_transport_websocket` resets its heartbeat timer after websocket
activity. The old timer can still have a timeout message already queued, and
the transport previously handled every heartbeat timeout without checking that
the reference matched the active timer.

## Goals

- Ignore stale websocket heartbeat timeout messages.
- Preserve the existing heartbeat send path for the active timer.
- Add an EUnit regression test in the module that owns the timer state record.
- Keep the static baseline useful on machines without Erlang installed.

## Implementation

- Matched heartbeat timeout messages against the active timer reference stored
  in `#state.heartbeat_interval`.
- Added a fallback timeout clause that ignores non-current heartbeat timer
  references.
- Added `stale_heartbeat_timer_is_ignored_test/0` under `-ifdef(TEST)`.
- Extended `scripts/check-baseline.sh` to preserve the stale-timer guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

`make test` is still skipped locally because Erlang `erl`/`escript` is not
installed in this environment.
