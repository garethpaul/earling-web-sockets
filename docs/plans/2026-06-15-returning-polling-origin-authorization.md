# Returning Polling Origin Authorization

Status: Completed

## Problem

Returning XHR and JSONP polling GET requests look up the supplied session and
dispatch the request to its transport process before consulting the listener's
Origin allow-list. The transport verifies Origin only when a message is later
sent, so an unauthorized request can occupy and link a known session's
long-poll connection while no response payload is available.

## Scope

- Authorize only returning XHR and JSONP polling GET requests before session
  lookup and transport dispatch.
- Preserve new-session authorization, polling POST authorization, missing-
  Origin compatibility, status codes, and valid long-poll behavior.
- Reuse the existing `authorize_session_request/2` helper and listener-owned
  Origin policy.
- Do not change dependencies, submodule identity, demo credentials, or merge
  any stacked pull request.

## Requirements

1. Reject an explicit Origin authorization failure before `ets:lookup/2` and
   `gen_server:cast/2` for both returning polling routes.
2. Respond with the existing HTTP 405 unauthorized response and leave session
   state untouched.
3. Preserve the existing 404 response for authorized requests with unknown
   session identifiers.
4. Add a mutation-sensitive source checker for both route orderings and wire it
   into the dependency-free baseline.
5. Keep operator and contributor guidance synchronized with the stronger
   returning-session boundary.

## Verification Plan

- Run the new checker first and prove the unmodified source fails it.
- Run `EARLING_STATIC_ONLY=1 make check` from the repository and an external
  working directory.
- Compile every Python checker and run `sh -n scripts/check-baseline.sh`.
- Reject hostile mutations for each route guard, ordering, dispatch boundary,
  documentation, completed status, and recorded verification.
- Record that Erlang EUnit and runtime transport execution remain unavailable
  when `erl` and `escript` are not installed.

## Work Completed

- Guarded both returning XHR and JSONP polling GET routes with the shared
  request Origin authorizer before session lookup and transport dispatch.
- Preserved authorized unknown-session 404 responses and the established 405
  response for explicit Origin denial.
- Added a dependency-free route-order checker and synchronized contributor,
  security, project, vision, and change guidance.

## Verification Completed

- Root and external-directory `EARLING_STATIC_ONLY=1 make check` passed all
  static maintenance, authorization-order, submodule, and PEM boundaries.
- The new checker passed and every Python checker compiled successfully;
  `sh -n scripts/check-baseline.sh` and `git diff --check` also passed.
- Ten isolated hostile mutations were rejected for the XHR guard, denial
  branch, status, lookup, and dispatch; the JSONP guard and dispatch;
  authorized unknown-session 404 behavior; documentation drift; and reopened
  plan status.
- Erlang EUnit was unavailable locally because `erl` and `escript` are not
  installed. No compile, transport-client, browser, HTTP/SSL demo, or runtime
  result is claimed.
