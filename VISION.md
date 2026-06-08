## Earling Web Sockets Vision

Earling Web Sockets is an Erlang Socket.IO server implementation sample based on
the socket.io-erlang codebase.

The repository is useful as a preserved Socket.IO 0.6-era Erlang implementation
with demos, transports, tests, and rebar build files. Project details live in
[`README.md`](README.md).

The goal is to keep the maintenance-mode server understandable and buildable
without pretending it tracks modern Socket.IO protocol changes.

The current focus is:

Priority:

- Preserve compatibility expectations for the old Socket.IO protocol family
- Keep Erlang crypto/SSL build prerequisites documented
- Maintain demo and test coverage around transports
- Avoid broad protocol rewrites without a compatibility plan

Next priorities:

- Add clear maintenance-status and supported-client notes
- Verify the rebar build and tests on a documented Erlang version
- Document SSL demo certificate usage
- Tighten contribution and known-issues sections that the README lists as TODOs

Contribution rules:

- One PR = one focused transport, build, test, or documentation change.
- Run the relevant Makefile/rebar test path before pushing Erlang changes.
- Preserve old protocol compatibility unless a migration note explains the break.
- Keep demo certificates clearly marked as test-only.

## Security

Socket servers and SSL demos need clear boundaries. Test certificates must not
be used as production credentials, and server changes should avoid unsafe
defaults for real deployments.

## What We Will Not Merge (For Now)

- Modern Socket.IO rewrites without a protocol compatibility plan
- Production credential material
- SSL or transport changes without test/demo verification
- Changes that remove maintenance-mode context from the README
