---
title: Demo TLS Fixture Integrity
type: security
status: completed
date: 2026-06-17
---

# Demo TLS Fixture Integrity

## Context

The repository intentionally tracks one encrypted certificate/private-key pair
for the legacy local SSL demo. The readiness gate restricts the allowed
filenames and documents that the material is test-only, but it does not prove
that the certificate still matches the key, that the key remains encrypted,
or that `demo/demo_ssl.erl` retains the password needed to open the fixture.
A replacement or mismatched file can therefore pass hosted checks while making
the documented SSL demo unusable or weakening the fixture boundary.

## Priority

1. Fail closed when either tracked TLS fixture is replaced or corrupted.
2. Prove the encrypted private key and certificate contain the same public key.
3. Keep the demo password, fixture identity, and test-only documentation in
   sync without claiming production TLS suitability or live SSL execution.

## Requirements

- Add a portable OpenSSL-backed checker for the exact tracked certificate and
  encrypted private key.
- Require the reviewed certificate SHA-256 fingerprint, encrypted PEM marker,
  successful fixture-password decryption, and matching certificate/key public
  keys.
- Require the demo source to retain the matching test-fixture password.
- Integrate the checker into `scripts/check-baseline.sh` and the canonical
  static-only GitHub Actions gate.
- Add mutation-sensitive regressions for certificate replacement, key
  replacement, password drift, encryption-marker removal, and public-key
  mismatch.
- Update maintained guidance and this plan with truthful local and hosted
  evidence.

## Implementation Units

### 1. TLS fixture checker

Files:

- `scripts/check-demo-tls-fixture.sh`
- `scripts/check-baseline.sh`

Use OpenSSL to validate the reviewed certificate fingerprint, decrypt the
test-only key with the password already present in the demo source, and compare
public-key digests. Diagnostics must identify the failed contract without
printing private-key material.

### 2. Regression and maintenance contracts

Files:

- `tests/check-demo-tls-fixture.sh`
- `.github/workflows/check.yml`
- `Makefile`

Keep the fixture tests dependency-free beyond OpenSSL and ordinary POSIX shell
tools. The hosted static gate must execute them without implying Erlang compile
or EUnit coverage.

### 3. Guidance and evidence

Files:

- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`
- `docs/plans/2026-06-17-demo-tls-fixture-integrity.md`

Document that fixture integrity is verified while the certificate remains
expired, test-only material unsuitable for production deployment.

## Validation

- Run shell syntax checks for all touched shell scripts.
- Run the focused TLS fixture regression suite.
- Run repository-root and external-directory `make check` with
  `EARLING_STATIC_ONLY=1`.
- Reject isolated mutations for the reviewed fingerprint, certificate, key,
  encrypted marker, fixture password, public-key match, workflow wiring,
  maintained guidance, plan status, and verification evidence.
- Audit the exact diff, executable modes, generated artifacts, whitespace,
  conflict markers, and credential-shaped additions.
- Require exact-head push and pull-request checks to pass before marking hosted
  verification complete.

## Scope Boundaries

- Do not replace or renew the historical fixture in this change.
- Do not claim certificate validity, trusted-chain validation, live TLS
  negotiation, Erlang compilation, EUnit, listener startup, or browser use.
- Do not expose or introduce production credentials.
- Do not merge or close this stacked pull request or its predecessors without
  explicit authorization.

## Verification Results

Implementation is complete. The OpenSSL-backed checker verified the reviewed
certificate fingerprint and expiry metadata, encrypted private-key shape,
fixture-password decryption, and matching certificate/key public keys. The
focused suite passed its clean case and five replacement or drift regressions.

Ten isolated hostile mutations were rejected across reviewed identity,
expiry, password, encryption, public-key matching, focused tests, workflow
wiring, maintained guidance, and plan status. The repository-root and
external-directory `make check` gates passed with `EARLING_STATIC_ONLY=1`.

No Erlang compile, EUnit, listener, transport-client, HTTP demo, SSL demo, or browser execution is claimed.

Both exact-head push and pull-request checks passed. On head
`e6867db7d6b4b0752d921df679b5873d7629f700`, push run `27663517326` and
pull-request run `27663518524` completed successfully.
