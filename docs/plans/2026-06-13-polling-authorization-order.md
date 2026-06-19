---
title: Polling POST Authorization Order
type: security
date: 2026-06-13
status: completed
execution: code
---

# Polling POST Authorization Order

## Summary

Authorize the polling POST request origin before parsing or decoding its body.
An unauthorized request should receive the existing 405 response without
spending work on attacker-controlled form data or Socket.IO frames.

## Requirements

- R1. Evaluate the shared CORS origin boundary before `parse_post/1`.
- R2. Parse and decode polling POST data only inside the authorized branch.
- R3. Preserve the existing unauthorized 405 response and authorized message,
  heartbeat, timer-reset, and success-response behavior.
- R4. Add a mutation-sensitive static contract that rejects moving body parsing
  ahead of authorization or duplicating the parse operation.
- R5. Run the repository baseline and record whether Erlang EUnit execution was
  available locally and in hosted checks.

## Verification Plan

- Run the focused authorization-order static contract.
- Run hostile source mutations that move parsing before authorization,
  duplicate parsing, or remove the authorized parse operation.
- Run `EARLING_STATIC_ONLY=1 make check` from the repository and an external
  working directory.
- Run `make test` when `erl` and `escript` are available; otherwise record the
  unavailable runtime truthfully and require the bounded hosted checks to pass.

## Non-Goals

- Changing CORS allow-list semantics or Origin header cardinality rules.
- Changing Socket.IO frame decoding, polling response formats, or HTTP routes.
- Modernizing the legacy rebar or Socket.IO 0.6 dependency stack.

## Verification

- `python3 scripts/check-polling-authorization-order.py
  src/socketio_transport_polling.erl` passed with Python 3.12.8.
- Four hostile source mutations were rejected: moving body parsing before the
  authorization branch, duplicating parsing, removing parsing, and removing
  frame decoding.
- `EARLING_STATIC_ONLY=1 make check` passed from the repository root and from an
  external working directory.
- EUnit was not executed locally because neither `erl` nor `escript` is
  installed. The stacked pull request's bounded hosted check remains the
  authoritative Erlang-capable validation.
