-module(socketio_transport_polling_tests).
-include_lib("eunit/include/eunit.hrl").

transport_xhr_polling_test_() ->
    socketio_transport_tests:transport_tests("xhr-polling").

transport_jsonp_polling_test_() ->
    socketio_transport_tests:transport_tests("jsonp-polling").
