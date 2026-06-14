---
title: Earling Legacy Runtime Verification Matrix
type: reliability
status: in_progress
date: 2026-06-14
---

# Earling Legacy Runtime Verification Matrix

## Status: In Progress

## Problem Frame

Portable static checks cover frame parsing, timer references, origin
normalization and authorization ordering, transport route guards, workflow
trust, and the pinned Socket.IO submodule identity. This host has no Erlang/OTP
or escript, so the legacy rebar compile, EUnit suite, transport handshakes, and
demo servers remain unexecuted.

## Scope Boundaries

- Do not change Erlang source, tests, dependencies, submodules, demo behavior,
  certificates, keys, configuration, or runtime compatibility.
- Do not add production credentials, private keys, certificates, cookies,
  session identifiers, payloads, screenshots, packet captures, or logs.
- Do not claim compile, EUnit, transport, HTTP, SSL, or browser execution from
  static Python and shell checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Requirements

- R1. Add an exact-commit matrix for OTP/rebar setup, dependency identity,
  compile, EUnit, WebSocket and fallback transports, origin allow/deny paths,
  heartbeat/timer behavior, HTTP and SSL demos, and shutdown/restart behavior.
- R2. Require isolated synthetic origins and payloads, sanitized evidence, and
  explicit `pass`, `fail`, `blocked`, or `not run` status.
- R3. Keep portable static checks, compile/EUnit, transport clients, browser
  evidence, and demo-server evidence separate.
- R4. Add mutation-sensitive contracts for the matrix, project guidance, and
  completed plan evidence.

## Implementation

1. Add the legacy runtime matrix with all scenarios marked `not run`.
2. Link it from project guidance and document fixture and evidence boundaries.
3. Extend the deterministic checker with scenario, status, and plan contracts.
4. Run focused, external-directory, mutation, artifact, and secret gates.

## Verification

- `sh -n scripts/check-baseline.sh`
- `make check` from repository and external working directories
- Python static checker compilation and execution
- Isolated hostile documentation mutations
- Exact diff, generated-artifact, certificate/key, and secret-pattern audits
