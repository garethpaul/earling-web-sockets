# Earling Legacy Runtime Verification Matrix

Use this matrix for exact-head evidence that cannot be inferred from portable
static checks. Run it in an isolated legacy-compatible Erlang/OTP environment
with synthetic origins, payloads, and clients. Record only sanitized outcomes;
never retain production credentials, private keys, certificates, cookies,
session identifiers, payload contents, screenshots, packet captures, or logs.

Commit: pending implementation commit
Pull request: pending
Evidence status: not run

| # | Scenario | Boundary | Required sanitized evidence | Status |
|---|---|---|---|---|
| 1 | Erlang and rebar environment | Legacy runtime | OTP release, ERTS release, architecture class, and rebar command status | not run |
| 2 | Socket.IO dependency identity | Dependency checkout | Expected commit, observed commit, submodule cleanliness, and fetch status | not run |
| 3 | Legacy project compile | Rebar compile | Exit status, warning count, and beam count | not run |
| 4 | EUnit suite | Rebar EUnit | Test count, failure count, skipped count, and elapsed-time bucket | not run |
| 5 | WebSocket allowed origin | Synthetic client | Origin class, handshake status, session result, and frame result | not run |
| 6 | WebSocket denied origin | Synthetic client | Origin class, rejection status, and session count delta | not run |
| 7 | XHR polling transport | Synthetic client | Request class, response status, session result, and frame result | not run |
| 8 | JSONP polling transport | Synthetic client | Callback-index class, response status, and wrapper result | not run |
| 9 | XHR multipart transport | Synthetic client | Origin class, multipart result, and session count delta | not run |
| 10 | HTMLFile transport | Synthetic client | Origin class, response status, and session count delta | not run |
| 11 | Heartbeat and timeout timers | Legacy runtime | Timer class, reset result, stale-message result, and elapsed-time bucket | not run |
| 12 | Malformed and oversized frames | Synthetic client | Payload class, decode result, process-liveness result, and error class | not run |
| 13 | HTTP demo lifecycle | Local demo | Bind class, startup result, request result, shutdown result, and restart result | not run |
| 14 | SSL demo fixture boundary | Local demo | Test-fixture identity, handshake result, warning class, and shutdown result | not run |
| 15 | Cross-Origin session reuse | Synthetic client | Creator Origin class, second allowed Origin class, lookup result, and session count delta | not run |
| 16 | Session identifier bounds | HTTP route | Identifier class, lookup result, response class, and process-liveness result | not run |
| 17 | POST resource bounds | HTTP route | Length/transfer class, parser-call count, response class, and process-liveness result | not run |
| 18 | JSONP preallocation bounds | HTTP route | Callback-index class, response class, and session count delta | not run |

## Evidence Rules

- Replace the pending commit and pull-request fields with the exact tested head
  before recording any scenario as `pass`, `fail`, or `blocked`.
- Use only `pass`, `fail`, `blocked`, or `not run`; explain blockers without
  embedding secrets, private identifiers, payloads, or machine paths.
- Keep portable static checks, compile/EUnit evidence, transport clients,
  browser evidence, and demo-server evidence separate.
- A Python checker, shell contract, or source review cannot mark a runtime
  scenario as passed.
- The tracked `demo/test_certificate.pem` and `demo/test_privkey.pem` files are
  test-only fixtures and cannot establish production TLS suitability.

No Erlang compile, EUnit, transport client, HTTP demo, SSL demo, or browser
scenario was executed for the complete legacy application. On Erlang/OTP 29,
the bundled 2012 `rebar` archive fails to load before dependency fetching or
compilation. The dependency-free `socketio_request_security` module does
compile on OTP 29 and its focused EUnit suite is recorded separately in the
2026-06-19 authorization/resource-boundary review plan.
