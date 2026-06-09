# Earling JSONP Index Length Guard

status: completed

## Context

The polling transport already rejected empty and non-digit JSONP callback
indexes before embedding them in a JavaScript response wrapper. That still left
arbitrarily long numeric indexes accepted, which is unnecessary for the legacy
Socket.IO JSONP callback table and makes the response construction boundary less
explicit.

## Objectives

- Preserve existing JSONP polling behavior for ordinary numeric callback
  indexes.
- Reject oversized numeric JSONP indexes before response construction.
- Add regression coverage for overlong indexes.
- Extend the static baseline and docs so the length bound remains visible.

## Work Completed

- Added a `MAX_JSONP_INDEX_LENGTH` guard in the polling transport.
- Added EUnit coverage for overlong JSONP index rejection.
- Extended the static baseline to require the length guard, regression test,
  and documentation wording.
- Documented the bounded callback index rule in README, SECURITY, VISION, and
  CHANGES.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `make lint`
- `make check`
- `git diff --check`

`scripts/check-baseline.sh` runs `make test` when Erlang/OTP `erl` and
`escript` are available on `PATH`.
