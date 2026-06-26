# Make Invocation Authority

status: completed

## Summary

Keep repository verification authoritative when callers provide additional
Makefiles or GNU Make modes that suppress execution or ignore errors.

## Problem

The root Makefile derived `ROOT` from the last loaded Makefile and used ordinary
single-colon recipes. A caller could load a later Makefile that replaced every
leaf recipe; the aggregate dependency graph remained present, yet each leaf
only ran caller-controlled success commands. Dry-run, touch, question, and
ignore-error modes could likewise return a false-green result.

## Design

Capture the first reviewed Makefile before later files are parsed. Use
double-colon public targets and attach a repository-owned authority prerequisite
through secondary expansion. A later single-colon replacement is invalid
because GNU Make forbids mixing rule kinds; a later double-colon append still
runs after the authority prerequisite, which rejects the expanded Makefile list
before target recipes execute. Reject `MAKEFILES`, caller `MAKEFLAGS`, and GNU
Make's non-executing or error-ignoring modes at parse time.

An in-recipe guard was rejected because the later file can replace that recipe.
A wrapper command was rejected because it would abandon the documented Make
interface instead of fixing its ownership boundary.

## Implementation

- Converted every public target to a double-colon rule.
- Added the `__repository-make-authority` prerequisite and exact Makefile-list
  comparison.
- Rejected preloaded Makefiles, caller invocation variables, and short/long
  non-executing or error-ignoring modes.
- Added three executable authority regressions to `make verify`.
- Updated the shell baseline and repository guidance.
- Socket.IO protocol behavior was unchanged.

## Verification Completed

- All three Make authority tests passed.
- Both single-colon replacement and double-colon append were rejected before
  the caller marker was created.
- All ten non-executing or error-ignoring modes were rejected with the
  documented diagnostic.
- Caller `MAKEFLAGS`, `MAKEFILES`, and `MAKEFILE_LIST` authority remained
  fail-closed.
- `EARLING_STATIC_ONLY=1 make check` passed from the repository root.
- Absolute-Make verification passed from an external working directory.
- Existing executable security boundary checks and the dependency-free Erlang
  security EUnit gate retained their prior behavior and claims.
- Shell syntax, Python compilation, `git diff --check`, generated-artifact,
  conflict-marker, and secret-shaped-content audits passed.
