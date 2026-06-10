# Earling Web Sockets CI Baseline

## Status: Completed

## Context

`earling-web-sockets` has a maintenance-mode Erlang Socket.IO baseline behind
`make check`. The checker runs static repository guards everywhere and runs
legacy rebar tests when Erlang/OTP is available.

## Objectives

- Run the existing `make check` wrapper in GitHub Actions.
- Keep the hosted job useful even when Erlang/OTP is not installed.
- Keep hosted coverage explicitly static until a compatible Erlang/OTP release
  is documented.
- Make the workflow presence part of the maintenance baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned checkout by commit, granted read-only repository access, enabled
  stale-run cancellation, and limited the job to five minutes.
- Set `EARLING_STATIC_ONLY=1` in the hosted job so runner image changes cannot
  silently select an unqualified Erlang runtime.
- Reused the existing checker behavior that runs static guards and conditionally
  runs rebar tests when `erl` and `escript` are available.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `EARLING_STATIC_ONLY=1 make check`
- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Add an Erlang/OTP setup step once the supported OTP version is documented for
  hosted CI.
