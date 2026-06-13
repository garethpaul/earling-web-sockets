# AGENTS.md

## Repository purpose

`garethpaul/earling-web-sockets` is a maintenance-mode Erlang Socket.IO 0.6 server implementation with legacy rebar build tooling, browser transport tests, and local demo pages.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `src` - primary source code
- `test` - tests and fixtures

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Follow the existing file layout and naming used by the checked-in sample.

## Testing guidance

- Test-related files detected: `demo/test_certificate.pem`, `demo/test_privkey.pem`, `test/`, `test/socketio_data_tests.erl`, `test/socketio_listener_tests.erl`, `test/socketio_transport_polling_tests.erl`, `test/socketio_transport_tests.erl`, `test/socketio_transport_websocket_tests.erl`, `test/socketio_transport_xhr_multipart_tests.erl`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- The SSL demo certificate and private key are checked in for local testing only.
- The only tracked certificate/key files are `demo/test_certificate.pem` and `demo/test_privkey.pem`; both are test-only local demo fixtures.
- Do not commit production certificates, private keys, tokens, or local rebar dependency caches.
- Build outputs such as `ebin`, `.eunit`, `deps`, logs, and the populated `priv/Socket.IO` submodule checkout should stay untracked.
- The default listener origin configuration in the legacy supervisor allows broad origins unless callers provide a narrower `origins` option.
- Malformed or relative Origin values are rejected before transport handlers apply the configured origin allow-list.
- Origin header verification must reject duplicate, empty, non-list, and comma-joined values before CORS headers are emitted.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
