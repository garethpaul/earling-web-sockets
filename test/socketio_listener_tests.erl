-module(socketio_listener_tests).

-include_lib("../include/socketio.hrl").
-include_lib("eunit/include/eunit.hrl").

empty_origins_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar",[])).

missing_origin_header_is_absent_test() ->
    ?assertEqual(undefined, socketio_listener:verify_origin_headers([], [{"foo.bar",80}])).

single_origin_header_is_verified_test() ->
    Headers = [{'Origin', "http://foo.bar"}],
    ?assertEqual(true, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

lowercase_atom_origin_header_is_verified_test() ->
    Headers = [{origin, "http://foo.bar"}],
    ?assertEqual(true, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

mixed_case_string_origin_header_is_verified_test() ->
    Headers = [{"oRiGiN", "http://foo.bar"}],
    ?assertEqual(true, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

binary_origin_header_is_verified_test() ->
    Headers = [{<<"ORIGIN">>, "http://foo.bar"}],
    ?assertEqual(true, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

malformed_origin_header_name_is_ignored_test() ->
    Headers = [{[invalid], "http://foo.bar"}],
    ?assertEqual(undefined, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

cross_representation_duplicate_origin_headers_are_rejected_test() ->
    Headers = [{'Origin', "http://foo.bar"}, {"origin", "http://foo.bar"}],
    ?assertEqual(false, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

duplicate_origin_headers_are_rejected_test() ->
    Headers = [{'Origin', "http://foo.bar"}, {'Origin', "http://foo.bar"}],
    ?assertEqual(false, socketio_listener:verify_origin_headers(Headers, [{"foo.bar",80}])).

comma_joined_origin_header_is_rejected_test() ->
    Headers = [{'Origin', "http://foo.bar,http://example.com"}],
    ?assertEqual(false, socketio_listener:verify_origin_headers(Headers, [{"*","*"}])).

empty_origin_header_is_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin_headers([{'Origin', ""}], [{"*","*"}])).

non_list_origin_header_is_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin_headers([{'Origin', invalid}], [{"*","*"}])).

all_allowed_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[{"a",80},{"*","*"}])).

host_allowed_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[{"a",80},{"foo.bar","*"}])).

mixed_case_request_host_allowed_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("HTTP://FOO.BAR",[{"foo.bar",80}])).

mixed_case_configured_host_allowed_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[{"Foo.Bar",80}])).

mixed_case_near_miss_host_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar.example",[{"Foo.Bar",80}])).

malformed_configured_origin_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar",[invalid,{foo,80},{"foo.bar",bad_port}])).

malformed_configured_entry_is_skipped_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[invalid,{"foo.bar",80}])).

host_but_not_port_allowed_origins_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar:89",[{"a",80},{"foo.bar",80}])).

all_at_port_allowed_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar:89",[{"a",80},{"*",89}])).

port_default_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[{"a",80},{"*",80}])).

https_port_default_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("https://foo.bar",[{"foo.bar",443}])).

non_web_scheme_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("ftp://foo.bar",[{"*","*"}])).

userinfo_origin_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://user@foo.bar",[{"*","*"}])).

path_origin_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar/socket",[{"*","*"}])).

trailing_origin_data_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar trailing",[{"*","*"}])).

invalid_origin_port_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar:65536",[{"*","*"}])).

malformed_origin_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("not a url",[{"*","*"}])).

relative_origin_rejected_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("/socket.io/1",[{"*","*"}])).
