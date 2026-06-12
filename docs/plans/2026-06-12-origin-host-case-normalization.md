# Earling Origin Host Case Normalization

## Status: Completed

## Goal

Make Socket.IO origin allow-list matching follow DNS hostname semantics without
weakening the existing complete-origin, scheme, port, and parser-boundary
checks.

## Prioritized Engineering Work

1. **Compare origin hosts case-insensitively (this change).** URI schemes and
   DNS hostnames are case-insensitive, but the current allow-list compares host
   strings exactly. Normalize both the parsed origin host and configured host
   during matching while preserving wildcard and exact-port behavior.
2. **Define Origin header cardinality handling (follow-up).** Transport modules
   currently obtain one proplist value. A future change should explicitly
   reject duplicate or comma-joined Origin values before allow-list matching.
3. **Bound central HTTP routing stalls (follow-up).** Returning POST requests
   synchronously call transport processes from the central HTTP gen_server. A
   future change should document and bound the timeout/failure behavior without
   changing legacy protocol semantics accidentally.

## Changes

- Replace exact host tuple clauses with small host and port match helpers.
- Treat `*` as the only host wildcard and compare all string hosts after
  lowercase normalization.
- Fail closed for malformed configured host or port values instead of allowing
  helper crashes.
- Add EUnit regressions for mixed-case request hosts, mixed-case configured
  hosts, and near-miss hostnames.
- Extend the static maintenance baseline, README, security policy, vision, and
  changelog with the canonical host comparison contract.

## Verification

- `EARLING_STATIC_ONLY=1 make check` passes.
- All 19 listener tests pass in an isolated Erlang 27.3.4 EUnit harness using
  the historical `ex_uri` record definitions and a standards-based URI adapter.
- `git diff --check` passes.
- Restoring exact host comparison fails the mixed-case configured-host
  regression.

## Work Completed

- Replaced exact host tuple clauses with guarded host and port match helpers.
- Lowercased parsed and configured string hosts only at comparison time,
  preserving the caller's configuration and the existing wildcard contract.
- Added mixed-case request/configuration, near-miss, malformed configuration,
  and malformed-entry recovery regressions.
- Extended the static baseline and operator documentation with the canonical
  DNS hostname behavior.
