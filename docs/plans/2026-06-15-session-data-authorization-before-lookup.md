---
title: Session Data Authorization Before Lookup
type: security
status: in_progress
date: 2026-06-15
execution: code
---

# Session Data Authorization Before Lookup

## Problem Frame

Incoming XHR polling, JSONP polling, XHR multipart, and htmlfile POST handlers
look up the supplied session ID before Origin authorization occurs in the
transport process. Unauthorized callers can therefore distinguish missing
sessions from existing sessions and cause dispatch to a live session before the
request is rejected. Authorization must precede lookup and dispatch.

## Prioritized Engineering Work

1. **P0 - Authorization ordering:** authorize every session-data request before
   reading the session table or calling a transport process.
2. **P1 - Runtime verification:** execute the sanitized listener matrix with
   allowed and denied Origins across all transports.
3. **P2 - Modern protocol migration:** move from the legacy Socket.IO stack to a
   maintained transport implementation.

This change implements P0 only. P1 remains in `RUNTIME_VERIFICATION.md`; P2 is
an architectural migration beyond this narrow hardening step.

## Scope Boundaries

- Cover the four POST session-data routes only.
- Preserve authorized session lookup, transport message shapes, success
  responses, and missing-session `404` behavior.
- Return the existing `405 unauthorized` response before lookup for denied
  Origins, regardless of whether the supplied session exists.
- Preserve transport-level authorization as defense in depth.
- Do not run a live listener or change Origin matching semantics.

## Requirements

- R1. Origin authorization must occur before `ets:lookup` for all four POST
  transport routes.
- R2. Denied requests must return `405 unauthorized` without session lookup or
  transport dispatch.
- R3. Authorized existing sessions must receive the same transport-specific
  data call as before.
- R4. Authorized missing sessions must retain the empty `404` response.
- R5. Static contracts must reject route omission, reordered authorization,
  transport mapping drift, documentation drift, and incomplete plan evidence.

## Implementation Units

### U1: Centralize Authorization-First Dispatch

Files:

- `src/socketio_http.erl`

Approach:

- Route each POST clause through one internal helper carrying the transport
  atom, session ID, request, and state.
- Authorize once before session lookup, then preserve existing transport call
  and missing-session response behavior.

### U2: Add Flow Verification

Files:

- `scripts/check-session-data-authorization.py`
- `scripts/check-baseline.sh`

Approach:

- Verify all four route clauses delegate to the helper with the correct
  transport atom.
- Verify the helper's authorization, denial, lookup, dispatch, and `404` order.

### U3: Preserve Guidance

Files:

- `AGENTS.md`
- `CHANGES.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `docs/plans/2026-06-15-session-data-authorization-before-lookup.md`

## Verification

- Focused Python flow checker.
- Repository and external-directory `make check`.
- Any available Erlang compile/EUnit gate.
- Hostile mutations for helper bypass, authorization order, route mapping,
  denial response, documentation, and completion evidence removal.
- Exact diff, generated artifact, conflict marker, demo credential, and secret
  audits.

## Risks

- Denied requests with nonexistent session IDs change from `404` to the same
  `405 unauthorized` response used elsewhere, intentionally removing the
  session-existence oracle.
- Portable static checks do not prove live Misultin or transport behavior.

## Status: In Progress
