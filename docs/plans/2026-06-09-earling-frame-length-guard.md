---
title: Earling Frame Length Guard
type: reliability
status: completed
date: 2026-06-09
---

# Earling Frame Length Guard

## Summary

Reject oversized declared Socket.IO frame body lengths before decode attempts to
split the payload body.

## Requirements

- R1. Preserve valid message, JSON message, and heartbeat decoding.
- R2. Return an empty decoded message list when a frame declares a body larger
  than the maintenance limit.
- R3. Add source-level EUnit coverage for oversized frame rejection.
- R4. Extend README, SECURITY, VISION, CHANGES, and the static baseline guard.
- R5. Do not change the legacy Socket.IO 0.6 framing format for normal frames.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
