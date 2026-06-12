-module(socketio_listener).
-behaviour(gen_server).

-ifdef(COMPILING_WITH_REBAR_AND_ERLC_HATES_DEPS).
-include_lib("ex_uri.hrl").
-else.
-include_lib("ex_uri/deps/ex_uri.hrl").
-endif.

%% API
-export([start/1, server/1]).
-export([start_link/2]).
-export([event_manager/1, origins/1, origins/2]).
-export([verify_origin/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


-record(state, {
          sup,
          origins
         }).

%%%===================================================================
%%% API
%%%===================================================================

start(Options) ->
    case supervisor:start_child(socketio_listener_sup_sup, [Options]) of
        {ok, Pid} ->
            Children = supervisor:which_children(Pid),
            {_, Listener, _, _} = lists:keyfind(socketio_listener, 1, Children),
            {ok, Listener};
        {error,{already_started, Pid}} ->
            Children = supervisor:which_children(Pid),
            {_, Listener, _, _} = lists:keyfind(socketio_listener, 1, Children),
            {ok, Listener}
    end.

server(Sup) ->
    Children = supervisor:which_children(Sup),
    {_, Server, _, _} = lists:keyfind(socketio_listener, 1, Children),
    Server.

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(Sup, Origins) ->
    gen_server:start_link(?MODULE, [Sup, Origins], []).

event_manager(Server) ->
    gen_server:call(Server, event_manager).

origins(Server) ->
    gen_server:call(Server, origins).

origins(Server, Origins) ->
    gen_server:call(Server, {origins, Origins}).

verify_origin(Origin, Origins) ->
    case catch ex_uri:decode(Origin) of
        {ok, #ex_uri{
                scheme = Scheme,
                authority = #ex_uri_authority{
                    userinfo = undefined,
                    host = Host,
                    port = Port
                },
                path = [],
                q = undefined,
                fragment = undefined
            }, ""}
          when Host =/= undefined, Host =/= "" ->
            case origin_port(Scheme, Port) of
                false ->
                    false;
                OriginPort ->
                    verify_origin_1({Host, OriginPort}, Origins)
            end;
        _ ->
            false
    end.

origin_port(Scheme, Port) ->
    case {string:to_lower(Scheme), Port} of
        {"http", undefined} -> 80;
        {"https", undefined} -> 443;
        {"http", Value} when is_integer(Value), Value > 0, Value =< 65535 -> Value;
        {"https", Value} when is_integer(Value), Value > 0, Value =< 65535 -> Value;
        _ -> false
    end.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([Sup, Origins]) ->
    {ok, #state{
       sup = Sup,
       origins = Origins
      }}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------

%% Origins
handle_call(origins, _From, #state{ origins = Origins } = State) ->
    {reply, Origins, State};

handle_call({origins, Origins}, _From,State) ->
    {reply, Origins, State#state{ origins = Origins }};
            
%% Event management
handle_call(event_manager, _From, #state{ sup = Sup } = State) ->
    Children = supervisor:which_children(Sup),
    {_, EventMgr, _, _} = lists:keyfind(socketio_listener_event_manager, 1, Children),
    {reply, EventMgr, State}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
verify_origin_1({Host, undefined}, Origins) ->
    verify_origin_1({Host, 80}, Origins);
verify_origin_1({Host, Port} = Origin, [{AllowedHost, AllowedPort}|Rest]) ->
    case origin_host_matches(Host, AllowedHost) andalso
         origin_port_matches(Port, AllowedPort) of
        true -> true;
        false -> verify_origin_1(Origin, Rest)
    end;
verify_origin_1(Origin, [_Invalid|Rest]) ->
    verify_origin_1(Origin, Rest);
verify_origin_1(_Origin, []) ->
    false.

origin_host_matches(_Host, "*") ->
    true;
origin_host_matches(Host, AllowedHost) when is_list(Host), is_list(AllowedHost) ->
    string:to_lower(Host) =:= string:to_lower(AllowedHost);
origin_host_matches(_Host, _AllowedHost) ->
    false.

origin_port_matches(_Port, "*") ->
    true;
origin_port_matches(Port, Port) ->
    true;
origin_port_matches(_Port, _AllowedPort) ->
    false.
