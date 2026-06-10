-module(socketio_listener_tests).

-include_lib("../include/socketio.hrl").
-include_lib("eunit/include/eunit.hrl").

empty_origins_test() ->
    ?assertEqual(false, socketio_listener:verify_origin("http://foo.bar",[])).

all_allowed_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[{"a",80},{"*","*"}])).

host_allowed_origins_test() ->
    ?assertEqual(true, socketio_listener:verify_origin("http://foo.bar",[{"a",80},{"foo.bar","*"}])).

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
