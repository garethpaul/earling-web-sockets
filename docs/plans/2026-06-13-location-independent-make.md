# Make Verification Location Independent

status: completed

## Context

The Makefile invokes `./scripts/check-baseline.sh` and `./rebar` relative to the
caller's current working directory. `make -f /absolute/path/Makefile check`
therefore fails outside the repository even though the completed polling plan
records an external-working-directory pass.

## Requirements

- Resolve the repository root from the loaded Makefile path.
- Run the baseline checker and bundled rebar from that root for every target.
- Preserve the Erlang/escript tool gates and static-only behavior.
- Add a mutation-sensitive checker contract and actual `/tmp` verification.
- Correct the completed polling plan's external-working-directory evidence
  without weakening its authorization-order claims.

## Scope Boundaries

- Do not change Erlang source, protocol behavior, dependencies, submodules, or
  hosted workflow behavior.
- Do not claim local EUnit execution while Erlang and escript are unavailable.

## Implementation

- Add a root variable based on `$(lastword $(MAKEFILE_LIST))`.
- Root the checker and rebar invocations through that variable.
- Extend static guidance and the baseline checker with the portability contract.

## Verification

- Run `EARLING_STATIC_ONLY=1 make check` from the repository root and `/tmp`.
- Confirm `make test` still reaches the explicit missing-tool gate.
- Run shell syntax, whitespace, exact-path, secret, artifact, and hostile
  mutation checks.

## Risks

- Runtime rebar behavior remains unverified locally until Erlang/OTP is
  installed; this change only corrects path resolution before that tool gate.

## Work Completed

- Rooted checker and bundled rebar invocations to the loaded Makefile path.
- Added static contracts and project guidance for caller-independent targets.
- Preserved the existing Erlang/escript preflight and static-only behavior.

## Verification Completed

- `EARLING_STATIC_ONLY=1 make check` passed from the repository root and an
  external working directory using the absolute Makefile path.
- Six isolated hostile mutations were rejected across root derivation, checker
  and rebar paths, guidance, changelog, and plan status.
- Shell syntax and `git diff --check` passed.
- `make test` reached the explicit missing-tool gate; EUnit was not executed
  because Erlang and escript are unavailable locally.
