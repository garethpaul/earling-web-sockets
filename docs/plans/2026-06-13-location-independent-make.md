# Make Verification Location Independent

status: in progress

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
