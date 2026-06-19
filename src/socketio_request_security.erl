-module(socketio_request_security).

-export([valid_session_id/1, valid_jsonp_index/1, post_body_status/1,
         same_session_origin/2]).

-define(MAX_POST_BODY_LENGTH, 1048576).
-define(MAX_JSONP_INDEX_LENGTH, 16).

valid_session_id(SessionId) when is_list(SessionId) ->
    valid_session_id(SessionId, 0);
valid_session_id(_) ->
    false.

valid_session_id([], 36) ->
    true;
valid_session_id([], _Position) ->
    false;
valid_session_id(_Remaining, Position) when Position >= 36 ->
    false;
valid_session_id([$-|Rest], Position)
  when Position =:= 8; Position =:= 13; Position =:= 18; Position =:= 23 ->
    valid_session_id(Rest, Position + 1);
valid_session_id([$4|Rest], 14) ->
    valid_session_id(Rest, 15);
valid_session_id([_Character|_Rest], 14) ->
    false;
valid_session_id([Variant|Rest], 19)
  when Variant =:= $8; Variant =:= $9; Variant =:= $a; Variant =:= $b ->
    valid_session_id(Rest, 20);
valid_session_id([_Character|_Rest], 19) ->
    false;
valid_session_id([Character|Rest], Position) ->
    case lower_hex(Character) of
        true -> valid_session_id(Rest, Position + 1);
        false -> false
    end.

valid_jsonp_index(Index) when is_list(Index), Index =/= [] ->
    valid_jsonp_index(Index, 0);
valid_jsonp_index(_) ->
    false.

valid_jsonp_index([], Count) ->
    Count > 0 andalso Count =< ?MAX_JSONP_INDEX_LENGTH;
valid_jsonp_index(_Remaining, Count) when Count >= ?MAX_JSONP_INDEX_LENGTH ->
    false;
valid_jsonp_index([Digit|Rest], Count) when Digit >= $0, Digit =< $9 ->
    valid_jsonp_index(Rest, Count + 1);
valid_jsonp_index(_, _Count) ->
    false.

post_body_status(Headers) ->
    case header_values(Headers, "transfer-encoding") of
        [] -> content_length_status(header_values(Headers, "content-length"));
        _ -> {error, 400, "unsupported transfer encoding"}
    end.

same_session_origin(Origin, Origin) ->
    true;
same_session_origin(_SessionOrigin, _RequestOrigin) ->
    false.

content_length_status([]) ->
    {error, 411, "content length required"};
content_length_status([Value]) ->
    case bounded_decimal(Value, ?MAX_POST_BODY_LENGTH) of
        {ok, _Length} -> ok;
        too_large -> {error, 413, "request body too large"};
        invalid -> {error, 400, "invalid content length"}
    end;
content_length_status(_) ->
    {error, 400, "invalid content length"}.

header_values(Headers, ExpectedName) when is_list(Headers) ->
    [Value || {Name, Value} <- Headers, header_name(Name, ExpectedName)];
header_values(_Headers, _ExpectedName) ->
    [invalid].

header_name(Name, ExpectedName) when is_atom(Name) ->
    string:to_lower(atom_to_list(Name)) =:= ExpectedName;
header_name(Name, ExpectedName) when is_list(Name) ->
    try string:to_lower(Name) of
        ExpectedName -> true;
        _ -> false
    catch
        _:_ -> false
    end;
header_name(Name, ExpectedName) when is_binary(Name) ->
    header_name(binary_to_list(Name), ExpectedName);
header_name(_Name, _ExpectedName) ->
    false.

bounded_decimal(Value, Maximum) when is_binary(Value) ->
    bounded_decimal(binary_to_list(Value), Maximum);
bounded_decimal(Value, Maximum) when is_list(Value), Value =/= [] ->
    bounded_decimal(Value, Maximum, 0);
bounded_decimal(_Value, _Maximum) ->
    invalid.

bounded_decimal([], _Maximum, Value) ->
    {ok, Value};
bounded_decimal([Digit|Rest], Maximum, Value) when Digit >= $0, Digit =< $9 ->
    Next = Value * 10 + Digit - $0,
    case Next =< Maximum of
        true -> bounded_decimal(Rest, Maximum, Next);
        false -> too_large
    end;
bounded_decimal(_Value, _Maximum, _Accumulated) ->
    invalid.

lower_hex(Character) when Character >= $0, Character =< $9 -> true;
lower_hex(Character) when Character >= $a, Character =< $f -> true;
lower_hex(_Character) -> false.
