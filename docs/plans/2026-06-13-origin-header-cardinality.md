---
title: Earling Origin Header Cardinality Boundary
type: security
date: 2026-06-13
status: planned
---

# Earling Origin Header Cardinality Boundary

## Summary

Reject duplicate and comma-joined HTTP `Origin` headers before CORS allow-list
matching so transport adapters cannot authorize one interpretation while an
intermediary or downstream component uses another.

## Problem Frame

The listener validates a single canonical HTTP or HTTPS origin, but polling and
XHR-multipart transports currently select the first `Origin` value from a
proplist. Repeated headers and comma-joined values are ambiguous and can be
interpreted differently across legacy HTTP stacks. The repository vision lists
this boundary as the next origin-validation priority.

## Requirements

- R1. Requests without an `Origin` header must preserve the current non-CORS
  behavior.
- R2. Exactly one list-valued `Origin` header may proceed to canonical origin
  verification.
- R3. Duplicate, empty, non-list, or comma-containing `Origin` values must fail
  closed before allow-list matching.
- R4. Polling and XHR-multipart transports must use one shared verifier rather
  than independently selecting a proplist value.
- R5. Existing canonical origin, case-insensitive hostname, wildcard, port, and
  malformed-input behavior must remain unchanged.
- R6. Listener regressions, source contracts, documentation, and completed-plan
  evidence must be enforced by `make check`.

## Implementation Units

### U1. Add Shared Header Verification

- **Files:** `src/socketio_listener.erl`, `test/socketio_listener_tests.erl`
- **Goal:** Classify absent, singular valid, and ambiguous origin headers, then
  cover duplicates, comma joins, empty values, and normal authorization.
- **Covers:** R1, R2, R3, R5

### U2. Route CORS Transports Through The Shared Boundary

- **Files:** `src/socketio_transport_polling.erl`,
  `src/socketio_transport_xhr_multipart.erl`
- **Goal:** Remove first-value selection from both CORS response paths.
- **Covers:** R3, R4

### U3. Enforce And Document The Contract

- **Files:** `scripts/check-baseline.sh`, `README.md`, `SECURITY.md`, `VISION.md`,
  `CHANGES.md`, `AGENTS.md`
- **Goal:** Keep source shape, regressions, maintenance guidance, and truthful
  verification evidence mandatory.
- **Covers:** R6

## Verification Plan

- Run `EARLING_STATIC_ONLY=1 make check`, shell syntax, and `git diff --check`.
- If `erl` and `escript` are available, run the full `make check` and record the
  listener test count; otherwise state that EUnit was not executed.
- Apply isolated mutations for restored first-value selection, accepted
  duplicate/comma-joined values, removed regressions, documentation drift, and
  incomplete plan evidence.
- Inspect exact paths, credential-like additions, dependency files, submodule
  identity, and generated artifacts before committing.

## Risks

- Some legacy clients or proxies may combine multiple Origin values; those
  requests will now be rejected intentionally instead of interpreted loosely.
- The local environment may remain unable to compile Erlang or run EUnit, so
  hosted static verification cannot substitute for runtime execution.
