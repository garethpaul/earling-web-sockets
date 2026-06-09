---
title: Earling Malformed Frame Decode
type: reliability
status: completed
date: 2026-06-09
---

# Earling Malformed Frame Decode

## Summary

Make `socketio_data:decode/1` fail closed for malformed Socket.IO frame input
instead of raising parser exceptions into transport handlers.

## Requirements

- R1. Preserve valid message, JSON message, and heartbeat decoding.
- R2. Return an empty decoded message list for malformed frame headers,
  truncated frame bodies, or invalid JSON frame bodies.
- R3. Add source-level EUnit coverage for malformed, truncated, and invalid JSON
  frames.
- R4. Update README, VISION, CHANGES, and the static baseline guard.
- R5. Do not change the legacy Socket.IO 0.6 framing format.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
