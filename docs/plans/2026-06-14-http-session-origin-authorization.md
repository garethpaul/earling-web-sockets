# HTTP Session Origin Authorization

Status: Active

## Problem

New XHR polling, JSONP polling, XHR multipart, and htmlfile requests generate a
Socket.IO session before the listener-owned Origin allow-list is consulted.
Several transport initializers send or schedule session data immediately, so a
rejected Origin can still allocate and expose session state.

## Scope

- Authorize only new HTTP transport sessions before `{session, generate, ...}`.
- Preserve missing-Origin compatibility and the existing listener allow-list.
- Preserve returning-session, POST, WebSocket, status-code, and transport flow.
- Do not change the legacy dependency tree or claim Erlang runtime execution.

## Requirements

1. Read request headers through the configured HTTP server module.
2. Reuse `socketio_listener:verify_origin_headers/2` and listener-owned origins.
3. Reject explicit authorization failure before session process creation,
   ETS insertion, client notification, or transport initialization.
4. Cover all four new HTTP session routes with mutation-sensitive static tests.
5. Record completed local verification and the unavailable Erlang limitation.

## Verification Plan

- Root and external-directory `make check`
- `python3 -m py_compile` for the new static checker
- `git diff --check`
- Hostile mutations for each route, helper delegation, ordering, documentation,
  completion status, and verification evidence
- Confirm `erl` and `escript` availability before making runtime claims
