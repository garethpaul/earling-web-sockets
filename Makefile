.PHONY: all deps compile lint test verify check check-tools force

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

lint: verify

verify:
	@"$(ROOT)/scripts/check-baseline.sh"

check: verify

force:
	@true
