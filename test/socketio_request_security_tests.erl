-module(socketio_request_security_tests).

-include_lib("eunit/include/eunit.hrl").

canonical_session_id_is_accepted_test() ->
    ?assert(socketio_request_security:valid_session_id(
              "550e8400-e29b-41d4-a716-446655440000")).

non_v4_session_id_is_rejected_test() ->
    ?assertNot(socketio_request_security:valid_session_id(
                 "550e8400-e29b-11d4-a716-446655440000")).

non_rfc_variant_session_id_is_rejected_test() ->
    ?assertNot(socketio_request_security:valid_session_id(
                 "550e8400-e29b-41d4-7716-446655440000")).

oversized_session_id_is_rejected_test() ->
    ?assertNot(socketio_request_security:valid_session_id(lists:duplicate(4096, $a))).

bounded_jsonp_index_is_accepted_test() ->
    ?assert(socketio_request_security:valid_jsonp_index("1234567890123456")).

oversized_jsonp_index_is_rejected_test() ->
    ?assertNot(socketio_request_security:valid_jsonp_index("12345678901234567")).

non_digit_jsonp_index_is_rejected_test() ->
    ?assertNot(socketio_request_security:valid_jsonp_index("12;alert(1)")).

bounded_content_length_is_accepted_test() ->
    ?assertEqual(ok, socketio_request_security:post_body_status(
                       [{"Content-Length", "1048576"}])).

oversized_content_length_is_rejected_test() ->
    ?assertEqual({error, 413, "request body too large"},
                 socketio_request_security:post_body_status(
                   [{'Content-Length', "1048577"}])).

duplicate_content_length_is_rejected_test() ->
    ?assertEqual({error, 400, "invalid content length"},
                 socketio_request_security:post_body_status(
                   [{"Content-Length", "1"}, {<<"content-length">>, "1"}])).

missing_content_length_is_rejected_test() ->
    ?assertEqual({error, 411, "content length required"},
                 socketio_request_security:post_body_status([])).

malformed_content_length_is_rejected_test() ->
    ?assertEqual({error, 400, "invalid content length"},
                 socketio_request_security:post_body_status(
                   [{"Content-Length", "+10"}])).

chunked_transfer_encoding_is_rejected_test() ->
    ?assertEqual({error, 400, "unsupported transfer encoding"},
                 socketio_request_security:post_body_status(
                   [{"Transfer-Encoding", "chunked"}, {"Content-Length", "10"}])).

same_canonical_origin_owns_session_test() ->
    Origin = {"https", "example.com", 443},
    ?assert(socketio_request_security:same_session_origin(Origin, Origin)).

different_allowed_origin_does_not_own_session_test() ->
    ?assertNot(socketio_request_security:same_session_origin(
                 {"https", "example.com", 443},
                 {"https", "other.example", 443})).

missing_origin_only_matches_missing_origin_test() ->
    ?assert(socketio_request_security:same_session_origin(undefined, undefined)),
    ?assertNot(socketio_request_security:same_session_origin(
                 undefined, {"https", "example.com", 443})).
