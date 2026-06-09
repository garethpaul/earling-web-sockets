.PHONY: all deps compile test verify check check-tools force

all: compile

check-tools:
	@command -v erl >/dev/null 2>&1 || { echo "Erlang/OTP 'erl' is required. Install Erlang before running legacy rebar tasks."; exit 127; }
	@command -v escript >/dev/null 2>&1 || { echo "Erlang/OTP 'escript' is required. Install Erlang before running legacy rebar tasks."; exit 127; }

deps: check-tools
	@./rebar get-deps

compile: deps
	@./rebar compile

test: check-tools force
	@./rebar eunit skip_deps=true

verify:
	@./scripts/check-baseline.sh

check: verify

force:
	@true
