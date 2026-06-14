# WebSocket Origin Authorization

Status: Completed

## Problem

Misultin WebSocket upgrades created Socket.IO sessions without applying the
listener-owned Origin allow-list used by the HTTP transports.

## Requirements

1. Read upgrade headers through the supported Misultin WebSocket API.
2. Authorize headers before generating a session.
3. Reuse the listener's duplicate, malformed, and allow-list validation.
4. Preserve absent-Origin compatibility and existing WebSocket message flow.

## Verification

- Root and external-directory `make check` passed static transport contracts.
- Six hostile mutations were rejected for header, authorization, ordering,
  listener delegation, documentation, and plan-status regressions.
- Erlang EUnit was unavailable locally and is not claimed.
