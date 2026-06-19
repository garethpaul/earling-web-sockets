.PHONY: all deps compile lint test security-test verify check check-tools force

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

all: compile

check-tools:
	@command -v erl >/dev/null 2>&1 || { echo "Erlang/OTP 'erl' is required. Install Erlang before running legacy rebar tasks."; exit 127; }
	@command -v escript >/dev/null 2>&1 || { echo "Erlang/OTP 'escript' is required. Install Erlang before running legacy rebar tasks."; exit 127; }

deps: check-tools
	@"$(ROOT)/rebar" get-deps

compile: deps
	@"$(ROOT)/rebar" compile

test: check-tools force
	@"$(ROOT)/rebar" eunit skip_deps=true

security-test: check-tools
	@tmp=$$(mktemp -d "$${TMPDIR:-/tmp}/earling-security.XXXXXX"); \
	trap 'rm -rf -- "$$tmp"' EXIT HUP INT TERM; \
	erlc -o "$$tmp" "$(ROOT)/src/socketio_request_security.erl" "$(ROOT)/test/socketio_request_security_tests.erl"; \
	erl -noshell -pa "$$tmp" -eval 'case eunit:test(socketio_request_security_tests, [verbose]) of ok -> halt(0); _ -> halt(1) end.'

lint: verify

verify:
	@"$(ROOT)/scripts/check-baseline.sh"
	@python3 "$(ROOT)/tests/check-security-boundaries.py"

check: verify security-test

force:
	@true
