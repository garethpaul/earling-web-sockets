---
title: Socket.IO Submodule Identity
type: supply-chain
status: completed
date: 2026-06-13
---

# Socket.IO Submodule Identity

## Summary

Require the legacy browser client to remain the repository's only submodule at
its canonical path, HTTPS source, and compatibility branch.

## Requirements

- R1. `.gitmodules` must contain exactly one section named for
  `priv/Socket.IO`.
- R2. The submodule path must remain `priv/Socket.IO`.
- R3. The source must remain the canonical LearnBoost HTTPS repository.
- R4. The compatibility branch must remain `06`.
- R5. Extra submodules and extra per-submodule options must fail closed.
- R6. The dependency-free hosted static path must verify the contract.

## Non-Goals

- Fetching the submodule or legacy Erlang dependencies.
- Updating the Socket.IO protocol version or repository ownership.
- Claiming Erlang compilation or EUnit coverage without the runtime toolchain.

## Work Completed

- Parsed `.gitmodules` as structured configuration.
- Documented the exact dependency identity boundary.
- Added fail-closed checks for section and option drift.

## Verification

- `EARLING_STATIC_ONLY=1 make check` passed the dependency-free hosted path.
- Changing the submodule source from HTTPS to HTTP failed the static gate.
- Adding an unreviewed `update` option failed the static gate.
- `sh -n scripts/check-baseline.sh` passed.
- `git diff --check` passed.
- Erlang compilation and EUnit were not claimed because `erl` and `escript`
  are unavailable locally.
