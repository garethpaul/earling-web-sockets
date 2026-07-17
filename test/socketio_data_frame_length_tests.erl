-module(socketio_data_frame_length_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("socketio.hrl").

%% These fixtures assert the EFFECTIVE Socket.IO frame body cap using literal
%% sizes, so they track the documented 1 MiB bound rather than restating
%% whatever ?MAX_FRAME_LENGTH happens to say.
%%
%% socketio_data:decode/1 wraps decoding in a catch-all that returns [] on any
%% exception. A fixture that declares an oversized length but supplies a short
%% body therefore returns [] whether the length guard rejected the frame or
%% lists:split/2 merely crashed on the missing bytes -- so it still passes when
%% ?MAX_FRAME_LENGTH is widened, and cannot verify the bound. Supplying the
%% complete body removes the exception path, so rejection is attributable to the
%% guard alone and a widened cap becomes observable as an accepted frame.

%% Collapse the decode result to a compact verdict: these fixtures carry ~1 MiB
%% bodies and asserting on the raw term would dump them into CI logs on failure.
classify([]) ->
    rejected;
classify([#msg{content = Content} | _]) when is_list(Content) ->
    {accepted, length(Content)};
classify(Other) ->
    {unexpected, Other}.

frame_at_the_maximum_length_is_decoded_test() ->
    Body = lists:duplicate(1048576, $a),
    ?assertEqual({accepted, 1048576},
                 classify(socketio_data:decode(
                            #msg{content = "~m~1048576~m~" ++ Body}))).

frame_one_byte_over_the_maximum_length_is_rejected_test() ->
    Body = lists:duplicate(1048577, $a),
    ?assertEqual(rejected,
                 classify(socketio_data:decode(
                            #msg{content = "~m~1048577~m~" ++ Body}))).
