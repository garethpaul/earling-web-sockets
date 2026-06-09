# Earling JSONP Index Guard

status: completed

## Context

The polling transport embedded the JSONP callback index directly into the
response wrapper. A malformed index could add script characters to the
generated JavaScript response instead of being treated as an invalid polling
request.

## Objectives

- Preserve existing JSONP polling behavior for numeric callback indexes.
- Reject empty or non-digit JSONP indexes before response construction.
- Add EUnit coverage for valid, empty, and script-like index values.
- Extend the static baseline and docs so the callback index guard remains
  visible.

## Work Completed

- Added `safe_jsonp_index/1` to accept digits-only string indexes.
- Returned a `400` response for invalid JSONP indexes.
- Added EUnit coverage in `socketio_transport_polling`.
- Documented the polling JSONP index boundary.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
