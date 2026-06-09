# Changes

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
