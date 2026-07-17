# Frame Body Bound Execution

status: completed

## Summary

Verify the documented 1 MiB Socket.IO frame body cap by executing it in the
hosted job, and pin the workflow's executable-test command rather than its step
name.

## Problem

`?MAX_FRAME_LENGTH` in `src/socketio_data.erl` bounds Socket.IO frame bodies at
1 MiB, and `README`, `SECURITY`, and `VISION` all promise that bound. No check
observed its value.

The fixtures covering it sit inside `-ifdef(TEST)` in `src/socketio_data.erl`,
so they run only under `make test` (rebar eunit). `make test` is invoked from a
single place, `scripts/check-baseline.sh`, and only when `EARLING_STATIC_ONLY`
is not `1`. The workflow sets `EARLING_STATIC_ONLY=1`, so the hosted job prints
`Skipping make test: static-only verification requested.` and the eunit suite
never executes. `make security-test`, the only step that runs Erlang, compiled
just `socketio_request_security.erl` and its tests.

Even when it runs, `oversized_frame_returns_empty_list_test` cannot detect a
widening. `decode/1` wraps decoding in a catch-all returning `[]` on any
exception, and the fixture declares length `1048577` while supplying a one-byte
body. With the cap widened, `lists:split/2` throws on the absent bytes, the
catch-all returns `[]`, and the fixture still passes. It passes identically at
`1048576` and `1073741824`.

The static baseline pins only that the text `MAX_FRAME_LENGTH`, `Length >
?MAX_FRAME_LENGTH`, and the fixture's *name* exist, plus the prose `1 MiB` in
three documents. Substring pins are satisfied by any value, so a 1024x widening
shipped green while the documents still promised 1 MiB.

Separately, `tests/check-security-boundaries.py` required only the string
`Run executable Erlang security tests` -- a step *name*. Replacing
`run: make security-test` with `run: 'true'` removed every executable test from
CI while the gate exited 0.

## Design

Assert the effective bound through behavior, using literal sizes and complete
bodies. Supplying the full body removes the exception path, so rejection is
attributable to the length guard alone and a widened cap becomes observable as
an accepted frame. Literal sizes mean the fixtures track the documented bound
instead of restating whatever the macro says, so they reject widenings and
narrowings while accepting an honest respelling such as `1024*1024`.

Dispatch the fixtures from `make security-test`, the step the workflow actually
runs. `socketio_data` compiles and decodes non-JSON frames without `jsx`, so the
dependency-free property of that step is preserved and the deliberate
`EARLING_STATIC_ONLY=1` posture is unchanged.

Restating the constant in a checker was rejected: a substring pin is satisfied by
any value, and the repository already demonstrates the correct shape --
`socketio_request_security_tests` bounds `?MAX_POST_BODY_LENGTH` with the literals
`"1048576"` and `"1048577"` and does catch a widening.

Making the hosted job run the full `make test` suite was rejected: it requires
`rebar get-deps`, which the static-only posture deliberately avoids.

## Implementation

- Added `test/socketio_data_frame_length_tests.erl` asserting the effective cap
  at `1048576` and `1048577` with complete bodies, collapsing results to a
  compact verdict so ~1 MiB fixtures are not dumped into CI logs on failure.
- Dispatched both eunit modules from `make security-test` and added
  `-I include` for `socketio.hrl`.
- Joined `erlc` and `erl` with `&&` so a compile failure fails the step directly.
- Pinned `run: make security-test` in the workflow, not just the step name.
- Pinned the eunit modules the recipe dispatches, stripping comment lines first
  so a commented-out mention cannot satisfy the pin while the live recipe runs
  fewer modules.
- Socket.IO protocol behavior was unchanged.

## Verification Completed

Exit codes; `sectest` = `make security-test`, `verify` = `EARLING_STATIC_ONLY=1 make verify`.

| mutation | before | after |
| --- | --- | --- |
| clean | 0 / 0 | 0 / 0 |
| `?MAX_FRAME_LENGTH` -> `1073741824` (1024x) | 0 / 0 MISS | 2 / 0 CAUGHT |
| `?MAX_FRAME_LENGTH` -> `1048577` (+1 byte) | 0 / 0 MISS | 2 / 0 CAUGHT |
| `?MAX_FRAME_LENGTH` -> `1048575` (narrowed) | not measured | 2 / 0 CAUGHT |
| `?MAX_FRAME_LENGTH` -> `1024*1024` (respell) | 0 / 0 | 0 / 0 ACCEPTED |
| workflow `run: make security-test` -> `run: 'true'` | 0 / 0 MISS | 0 / 2 CAUGHT |
| frame module dropped from recipe | not measured | 0 / 2 CAUGHT |
| comment-decoy `security-test::` block plus gutted recipe | not measured | 0 / 2 CAUGHT |

- The respell row is the control: the fixtures accept an honest refactor to the
  same value while rejecting widenings and narrowings, so they read the effective
  value rather than matching source text.
- Directly executing the repository's own `oversized_frame_returns_empty_list_test`
  confirmed it passes at both `1048576` and `1073741824`.
- `make security-test` reports 18 tests, up from 16.
- `EARLING_STATIC_ONLY=1 make check` passed from the repository root.
- A widened cap was confirmed to accept a 1048577-byte frame that the clean cap
  rejects.
- `MAX_FRAME_LENGTH_DIGITS` (7) independently limits declared lengths to
  9,999,999 bytes, so widening `?MAX_FRAME_LENGTH` alone raises the effective cap
  from 1 MiB to about 9.5 MiB rather than to the widened value; the 8-digit case
  remains rejected.
- Not verified here: `make test` (rebar eunit) still requires `rebar get-deps`
  and remains unexecuted in the hosted job, so `test/socketio_listener_tests.erl`,
  `test/socketio_transport_tests.erl`, `test/prop_transport.erl`, and the
  remaining transport suites continue to have no hosted execution. This change
  does not address that.
