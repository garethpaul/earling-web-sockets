#!/usr/bin/env python3
from pathlib import Path


root = Path(__file__).resolve().parents[1]
source = (root / "src/socketio_listener.erl").read_text()
tests = (root / "test/socketio_listener_tests.erl").read_text()

source_contracts = (
    "origin_header_values(Headers)",
    "origin_header_name(Name) when is_atom(Name)",
    "origin_header_name(Name) when is_list(Name)",
    "origin_header_name(Name) when is_binary(Name)",
    'string:to_lower(atom_to_list(Name)) =:= "origin"',
    "case catch string:to_lower(Name) of",
    "origin_header_name(binary_to_list(Name))",
)
test_contracts = (
    "lowercase_atom_origin_header_is_verified_test",
    "mixed_case_string_origin_header_is_verified_test",
    "binary_origin_header_is_verified_test",
    "malformed_origin_header_name_is_ignored_test",
    "cross_representation_duplicate_origin_headers_are_rejected_test",
)

for contract in source_contracts:
    if contract not in source:
        raise SystemExit(f"Origin header-name normalization source contract missing: {contract}")

for contract in test_contracts:
    if contract not in tests:
        raise SystemExit(f"Origin header-name normalization regression missing: {contract}")

if "proplists:get_all_values('Origin', Headers)" in source:
    raise SystemExit("Origin verification must not retain exact-atom-only lookup.")

print("Origin header-name normalization checks passed.")
