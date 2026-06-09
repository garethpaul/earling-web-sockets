---
title: Earling Web Sockets Check Wrapper
date: 2026-06-08
status: completed
execution: code
---

## Context

The legacy Erlang Socket.IO project already has a baseline script and rebar
test path, but its Makefile does not expose the repository-standard
`make check` command.

## Goals

- Add `verify` and `check` Makefile targets that run the existing baseline
  script.
- Keep `make test` focused on the legacy rebar EUnit path when Erlang/OTP is
  available.
- Document and preserve the wrapper through README, CHANGES, and the baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
