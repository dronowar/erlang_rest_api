-module(hello_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
%-export([resource_exists/2]).
-export([content_types_provided/2]).

%% Callback Callbacks
-export([hello_to_json/2]).

init(Req, _State) ->
    % {_, Req1} = cowboy_session:set(<<"user_id">>, 15, Req),
    % {Value, Req2} = cowboy_session:get(<<"user_id">>, Req1),
    % io:format("session value: ~p~n", [Value]),
    Message = [hello, <<"Good day">>],
    {cowboy_rest, Req, Message}.

allowed_methods(Req, State) ->  
    {[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, []}, hello_to_json}
    ], Req, State}.

hello_to_json(Req, State) ->
    {jiffy:encode(State), Req, State}.
