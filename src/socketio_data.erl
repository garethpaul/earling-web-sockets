-module(socketio_data).
-include_lib("socketio.hrl").
-export([encode/1, decode/1]).

%%%%%%%%%%%%%%%%%%%%
%%% The Sockets.js server-side protocol as processed by https://github.com/LearnBoost/Socket.IO-node/blob/master/lib/socket.io/utils.js
%%%%%%%%%%%%%%%%%%%%
%%
%% Frame: ~m~
%% Message: some string
%% JSON Message: ~j~ ++ String Version of JSON object
%% Heartbeat: ~h~ ++ Index
%% Result: Frame ++ Length of Message ++ Frame ++ Message
-define(FRAME, "~m~").
-define(JSON_FRAME, "~j~").
-define(JSON_FRAME_LENGTH, 3).
-define(HEARTBEAT_FRAME, "~h~").
-define(HEARTBEAT_FRAME_LENGTH, 3).
-define(MAX_FRAME_LENGTH, 1048576).
-define(MAX_FRAME_LENGTH_DIGITS, 7).


encode(#msg{ content = Content, json = false }) when is_list(Content) ->
    Length = integer_to_list(length(Content)),
    ?FRAME ++ Length ++ ?FRAME ++ Content;

encode(#msg{ content = Content, json = true }) ->
    JSON = binary_to_list(jsx:term_to_json(Content)),
    Length = integer_to_list(length(JSON) + ?JSON_FRAME_LENGTH),
    ?FRAME ++ Length ++ ?FRAME ++ ?JSON_FRAME ++ JSON;

encode(#heartbeat{ index = Index }) ->
    String = integer_to_list(Index),
    Length = integer_to_list(length(String) + ?HEARTBEAT_FRAME_LENGTH),
    ?FRAME ++ Length ++ ?FRAME ++ ?HEARTBEAT_FRAME ++ String.

decode(#msg{content=Str}) when is_list(Str) ->
    try header(Str)
    catch
        _:_ ->
            []
    end.

header(?FRAME ++ Rest) ->
    header(Rest, []).

header(?FRAME ++ Rest=[_|_], Acc)->
    case safe_frame_length(Acc) of
	false ->
	    [];
	Length ->
	    body(Length, Rest)
    end;
header([N|Rest], Acc) when N >= $0, N =< $9,
			    length(Acc) < ?MAX_FRAME_LENGTH_DIGITS ->
    header(Rest, [N|Acc]);
header([N|_Rest], _Acc) when N >= $0, N =< $9 ->
    [].

safe_frame_length([]) ->
    false;
safe_frame_length(Acc) ->
    Length = list_to_integer(lists:reverse(Acc)),
    case Length =< ?MAX_FRAME_LENGTH of
	true ->
	    Length;
	false ->
	    false
    end.

body(Length, _Body) when Length < 0; Length > ?MAX_FRAME_LENGTH ->
    [];
body(Length, ?JSON_FRAME++Body) ->
    json(Length-?JSON_FRAME_LENGTH, Body);
body(Length, ?HEARTBEAT_FRAME++Body) ->
    heartbeat(Length-?HEARTBEAT_FRAME_LENGTH, Body);
body(Length, Body) ->
    {Current, Rest} = lists:split(Length, Body),
    [#msg{content=Current} | handle_rest(Rest)].

json(Length, Body) ->
    {Object, Rest} = lists:split(Length, Body),
    [#msg{content=jsx:json_to_term(list_to_binary(Object), [{strict,false}]), json=true} |
     handle_rest(Rest)].

heartbeat(Length, Body) ->
    {Heart, Rest} = lists:split(Length, Body),
    [#heartbeat{index=list_to_integer(Heart)} | handle_rest(Rest)].

handle_rest([]) -> [];
handle_rest(X) -> decode(#msg{content=X}).

%% TESTS
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
%% For more reliable tests, see the proper module in tests/prop_transport.erl

simple_msg_test() ->
    [X] = decode(#msg{content="~m~11~m~Hello world"}),
    ?assertMatch("Hello world", X#msg.content).

complex_msg_test() ->
    [X] = decode(#msg{content="~m~11~m~Hello~world"}),
    ?assertMatch("Hello~world", X#msg.content).

simple_heartbeat_test() ->
    [X] = decode(#msg{content="~m~4~m~~h~0"}),
    ?assertMatch(0, X#heartbeat.index).

simple_json_test() ->
    [X] = decode(#msg{content="~m~20~m~~j~{\"hello\":\"world\"}"}),
    ?assertMatch(#msg{content=[{<<"hello">>,<<"world">>}], json=true}, X).

json_encoding_test() ->
    JSON = [{<<"hello">>,<<"world">>}],
    Msg = #msg{content = JSON, json=true},
    Data = encode(Msg),
    [X] = decode(#msg{content=Data}),
    ?assertMatch(#msg{content=JSON, json=true}, X).

malformed_frame_returns_empty_list_test() ->
    ?assertEqual([], decode(#msg{content="not a socket.io frame"})).

truncated_frame_returns_empty_list_test() ->
    ?assertEqual([], decode(#msg{content="~m~20~m~short"})).

invalid_json_frame_returns_empty_list_test() ->
    ?assertEqual([], decode(#msg{content="~m~4~m~~j~{"})).

oversized_frame_returns_empty_list_test() ->
    ?assertEqual([], decode(#msg{content="~m~1048577~m~a"})).

overlong_frame_length_prefix_returns_empty_list_test() ->
    Prefix = lists:duplicate(64, $9),
    ?assertEqual([], decode(#msg{content="~m~" ++ Prefix ++ "~m~a"})).

-endif.
