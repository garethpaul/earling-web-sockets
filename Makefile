.DEFAULT_GOAL := all

.PHONY: __repository-make-authority all deps compile lint test security-test verify check check-tools force
.SECONDEXPANSION:

override SHELL := /bin/sh
override .SHELLFLAGS := -c
ifneq ($(filter command line,$(origin MAKEFLAGS)),)
$(error MAKEFLAGS must not be overridden for repository verification)
endif
override REPOSITORY_MAKE_FIRST_FLAGS := $(firstword $(MAKEFLAGS))
ifneq ($(filter -%,$(REPOSITORY_MAKE_FIRST_FLAGS)),)
override REPOSITORY_MAKE_FIRST_FLAGS :=
endif
override REPOSITORY_MAKE_SHORT_FLAGS := $(REPOSITORY_MAKE_FIRST_FLAGS) $(filter-out --%,$(filter -%,$(MAKEFLAGS)))
ifneq ($(findstring n,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring t,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring q,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring i,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(filter --just-print --dry-run --recon --touch --question --ignore-errors,$(MAKEFLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override REPOSITORY_MAKEFILE := $(value MAKEFILE_LIST)
override EXPECTED_MAKEFILE_LIST := $(value MAKEFILE_LIST)
override CURRENT_MAKEFILE_LIST = $(value MAKEFILE_LIST)
export REPOSITORY_MAKEFILE EXPECTED_MAKEFILE_LIST CURRENT_MAKEFILE_LIST
override ROOT := $(shell path='$(subst ','"'"',$(REPOSITORY_MAKEFILE))'; path=$$(printf '%s' "$$path" | /usr/bin/sed 's/^ //'); /usr/bin/dirname -- "$$path")
export ROOT

all deps compile lint test security-test verify check check-tools force:: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
all deps compile lint test security-test verify check check-tools force:: __repository-make-authority

__repository-make-authority::
	@if [ "$$CURRENT_MAKEFILE_LIST" != "$$EXPECTED_MAKEFILE_LIST" ]; then \
		printf '%s\n' 'multiple -f Makefiles are not supported' >&2; \
		exit 1; \
	fi

all:: compile

check-tools::
	@command -v erl >/dev/null 2>&1 || { echo "Erlang/OTP 'erl' is required. Install Erlang before running legacy rebar tasks."; exit 127; }
	@command -v escript >/dev/null 2>&1 || { echo "Erlang/OTP 'escript' is required. Install Erlang before running legacy rebar tasks."; exit 127; }

deps:: check-tools
	@"$(ROOT)/rebar" get-deps

compile:: deps
	@"$(ROOT)/rebar" compile

test:: check-tools force
	@"$(ROOT)/rebar" eunit skip_deps=true

security-test:: check-tools
	@tmp=$$(mktemp -d "$${TMPDIR:-/tmp}/earling-security.XXXXXX"); \
	trap 'rm -rf -- "$$tmp"' EXIT HUP INT TERM; \
	erlc -o "$$tmp" "$(ROOT)/src/socketio_request_security.erl" "$(ROOT)/test/socketio_request_security_tests.erl"; \
	erl -noshell -pa "$$tmp" -eval 'case eunit:test(socketio_request_security_tests, [verbose]) of ok -> halt(0); _ -> halt(1) end.'

lint:: verify

verify::
	@"$(ROOT)/scripts/check-baseline.sh"
	@python3 "$(ROOT)/tests/check-security-boundaries.py"
	@PYTHONDONTWRITEBYTECODE=1 python3 "$(ROOT)/tests/test-makefile-root.py"

check:: verify security-test

force::
	@true
