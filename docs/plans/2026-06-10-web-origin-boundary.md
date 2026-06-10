# Earling Web Origin Boundary

## Status: Completed

## Goal

Ensure configured Socket.IO origin allow-lists are evaluated only against a
canonical web origin rather than any URI that happens to contain an allowed
host and port.

## Changes

- Require the legacy URI parser to consume the entire value and produce an
  `http` or `https` URI with a non-empty host.
- Reject userinfo, paths, queries, fragments, unsupported schemes, parser
  leftovers, and explicit ports outside the valid TCP range.
- Normalize omitted HTTP ports to 80 and omitted HTTPS ports to 443 before
  applying existing host/port wildcard rules.
- Add EUnit regressions for HTTPS defaults and each newly rejected origin
  shape, while preserving the existing malformed and relative-origin tests.
- Extend the static maintenance baseline and security documentation with the
  canonical origin contract.

## Verification

- `EARLING_STATIC_ONLY=1 make check`
- `make check`
- `git diff --check`
- OTP 22 compile with warnings as errors for `socketio_listener.erl` and its
  EUnit module, using the historical `ex_uri` parser regenerated from its ABNF
  source; all 14 listener tests pass.
- Runtime mutations permit FTP and parser leftovers in turn; the corresponding
  scheme and trailing-data EUnit regressions fail for each weakened variant.
- Static mutations also confirm the maintenance baseline rejects removal of
  scheme enforcement and full-input consumption.

Full repository rebar execution remains contingent on a compatible legacy
dependency environment; hosted verification intentionally stays static until
that runtime is documented.
