# Earling Frame Length Prefix Guard

Status: Completed
Date: 2026-06-09

## Goal

Reject hostile Socket.IO frame length prefixes before integer parsing can spend
work on arbitrarily long digit strings.

## Changes

- Added a digit bound for Socket.IO frame length prefixes.
- Moved declared frame length conversion through a `safe_frame_length` helper.
- Added a decode regression for overlong frame length prefixes.
- Extended the static baseline, README, security notes, changelog, and vision
  with the frame length prefix guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
