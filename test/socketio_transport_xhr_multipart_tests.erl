-module(socketio_transport_xhr_multipart_tests).
-include_lib("eunit/include/eunit.hrl").

transport_xhr_polling_test_() ->
    socketio_transport_tests:transport_tests(firefox,"xhr-multipart").
