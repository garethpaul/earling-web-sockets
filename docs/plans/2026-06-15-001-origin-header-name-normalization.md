# Normalize Origin Header Names

status: planned

## Problem

The shared Origin verifier reads only the exact atom `'Origin'`. The Misultin
adapter forwards the HTTP parser's header-name representation, so a lowercase,
mixed-case, string, or binary `Origin` name can be missed and classified as an
absent header. Existing handlers allow absent Origin values, creating an
authorization bypass when a present header is represented differently.

## Requirements

1. Match Origin field names case-insensitively across atom, list, and binary
   representations without creating atoms from request data.
2. Preserve the current absent-header result and single-value origin verifier.
3. Count matching names across representations so duplicates still fail
   closed.
4. Preserve value cardinality, comma, type, canonical URI, host, scheme, port,
   and handler authorization-order behavior.
5. Add mutation-sensitive EUnit, source, documentation, and completed-plan
   contracts.

## Scope Boundaries

- Do not change the policy that requests without an Origin header are allowed.
- Do not change transport handlers, session generation, CORS response values,
  dependencies, submodule identity, or demo credentials.
- Do not claim Erlang compile, EUnit, transport-client, browser, or demo-server
  runtime execution where the toolchain is unavailable.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation

1. Add small header-name and value-collection helpers in the listener.
2. Route `verify_origin_headers/2` through the collected case-insensitive
   values.
3. Add EUnit cases for lowercase atoms, mixed-case strings, binary names, and
   cross-representation duplicates.
4. Extend the dependency-free static baseline and repository guidance.
5. Run checker compilation, static gates, hostile mutations, and final audits.

## Verification

Pending implementation and bounded validation.
