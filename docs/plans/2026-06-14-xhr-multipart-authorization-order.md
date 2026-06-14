---
title: XHR Multipart POST Authorization Order
type: security
date: 2026-06-14
status: planned
execution: code
---

# XHR Multipart POST Authorization Order

## Summary

Authorize `xhr-multipart` POST request origins before parsing or decoding their
bodies. A disallowed Origin must receive the existing unauthorized response
without spending work on attacker-controlled form data or Socket.IO frames.

## Requirements

- R1. Evaluate the shared Origin header boundary before `parse_post/1`.
- R2. Parse and decode multipart POST data only in the allowed or absent-Origin
  branch, preserving the legacy non-browser client path.
- R3. Preserve authorized message, heartbeat, timer-reset, and success behavior.
- R4. Add a mutation-sensitive static contract that rejects early, duplicated,
  or missing body parsing and decoding.
- R5. Run the static gate from the repository and an external working directory;
  run EUnit when Erlang is available and otherwise rely on hosted Erlang checks.

## Non-Goals

- Changing Origin allow-list or header-cardinality semantics.
- Changing polling, htmlfile, websocket, or XHR multipart response formats.
- Modernizing legacy rebar or Socket.IO 0.6 dependencies.

## Planned Verification

- Focused authorization-order static contract.
- Isolated hostile source mutations.
- `EARLING_STATIC_ONLY=1 make check` from repository and external directories.
- `make test` when `erl` and `escript` are available.
- Exact intended-path, artifact, whitespace, conflict-marker, and changed-line
  credential-pattern audits.
