# Security Policy

WebSocket upgrades authorize Origin headers before creating sessions.
New HTTP transport requests authorize Origin headers before creating sessions.
Returning polling GET requests authorize Origin headers before session lookup or transport dispatch.
Session data POST requests authorize Origin headers before session lookup or transport dispatch.

## Supported Versions

The supported security scope for `earling-web-sockets` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: socket-io for earling

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/earling-web-sockets` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be a public sample, documentation, or utility project. The active security scope is the code and documentation on the default branch.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found database, model, query, or persistence-related code; changes in those areas should receive security-focused review before merge.
- No primary dependency manifest was detected in the repository root. If dependencies are added later, include a manifest and prefer reproducible installation instructions.
- `demo/test_certificate.pem` and `demo/test_privkey.pem` are the only tracked
  certificate/key files, and both are test-only fixtures for local SSL demos.
  Do not commit production certificates, private keys, tokens, generated
  secrets, local rebar dependency caches, or machine-local configuration.
- OpenSSL verifies the reviewed demo certificate fingerprint, historical
  expiry metadata, encrypted private-key shape, fixture password, and matching
  public keys. The expired self-signed pair is not production credential or
  trust-chain material.
- GitHub Actions runs the static maintenance `make check` baseline on Ubuntu
  24.04 with pinned checkout, disabled credential persistence, read-only
  repository access, and a five-minute timeout.
- Invoke repository verification with this Makefile alone. Additional `-f` files,
  preloaded Makefiles, caller `MAKEFLAGS`, and non-executing or
  error-ignoring modes fail closed before security gates run.
- The static baseline permits exactly one submodule: `priv/Socket.IO` at the
  canonical LearnBoost HTTPS URL and exact reviewed `0.6` gitlink
  `7a5197c1e74d1f3a050b330e41e4b6e63afb209c`. URL, path, section, option, and
  gitlink drift are rejected; the upstream repository has no `06` branch.
- Runtime compatibility, transport, and demo-server claims require the
  exact-head runtime verification matrix. The tracked demo certificate and
  private key are test-only fixtures and cannot establish production TLS
  suitability.

## Service and API Notes

For web services, APIs, sockets, or scraping workflows, prioritize reports involving authentication bypass, authorization errors, injection, server-side request forgery, unsafe deserialization, credential leakage, data exposure, or denial-of-service conditions. Use test accounts and minimal proof-of-concept traffic only.

Polling JSONP callback indexes must stay restricted to bounded non-empty digit
strings before the JavaScript response wrapper is constructed.

Origin allow-list checks require a complete HTTP/HTTPS origin without userinfo,
paths, queries, fragments, parser leftovers, or invalid explicit ports. Omitted
ports normalize to 80 for HTTP and 443 for HTTPS before matching. Parsed and
configured DNS hostnames compare case-insensitively, without treating suffixes
or near-miss names as equal. Duplicate, empty, non-list, and comma-joined
Origin headers fail closed before a transport emits CORS response headers.
Origin field names must be matched case-insensitively across atom, string, and
binary representations without converting request data into atoms.
Polling POST bodies are not parsed or decoded until that Origin authorization
succeeds.
XHR multipart POST bodies follow the same fail-closed ordering and return the
legacy unauthorized response before parsing disallowed requests.
HTMLFile POST bodies also authorize first and return the legacy unauthorized
response without parsing or decoding disallowed requests.
Authorized sessions are owned by the canonical Origin identity that created
them. A different allow-listed Origin cannot reuse a known session ID for
returning polling or POST dispatch. Session IDs must be canonical lowercase
UUIDv4 values before ETS lookup.

Transport POSTs require exactly one decimal `Content-Length` no larger than
1 MiB. Duplicate/malformed lengths and transfer encodings fail before the
legacy body parser. JSONP callback indexes fail before session allocation.

Socket.IO frame bodies are capped at 1 MiB before payload splitting so
oversized declared frame lengths fail closed during decode.
Socket.IO frame length prefixes are digit-bounded before integer parsing.

The bundled 2012 rebar archive is not loadable by Erlang/OTP 29. Hosted checks
therefore execute the dependency-free request-boundary EUnit suite and static
contracts, while the historical full compile/EUnit path remains a separately
documented legacy-runtime requirement.

## Dependency and Supply Chain Security

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
