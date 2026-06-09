---
title: Earling Demo Credential Boundary
date: 2026-06-09
status: completed
execution: docs-and-guardrail
---

## Context

The repository intentionally tracks `demo/test_certificate.pem` and
`demo/test_privkey.pem` for local SSL demo coverage. That exception needs to
stay narrow so future maintenance does not accidentally commit production
certificates, private keys, dependency checkouts, or generated Erlang outputs.

## Goals

- Keep the two local demo SSL fixtures explicitly documented as test-only.
- Reject any additional tracked certificate or key material.
- Preserve `.gitignore` coverage for generated Erlang, rebar, log, and
  Socket.IO submodule checkout artifacts.
- Keep the guard available on machines that do not have Erlang installed.

## Implementation

- Extended `scripts/check-baseline.sh` to enforce the only allowed tracked
  certificate/key files.
- Added static checks for `.gitignore` entries that keep generated build and
  dependency artifacts out of version control.
- Documented the demo credential boundary in `README.md`, `SECURITY.md`, and
  `VISION.md`.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

`make test` is still skipped locally because Erlang `erl`/`escript` is not
installed in this environment.
