# Changes

## 2026-06-09

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
