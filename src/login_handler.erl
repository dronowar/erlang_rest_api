-module(login_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
%-export([resource_exists/2]).
-export([content_types_provided/2]).

%% Callback Callbacks
-export([login_to_json/2]).

init(Req, State) ->
    {ok, PostVals, Req1} = cowboy_req:read_urlencoded_body(Req),
    Email = proplists:get_value(<<"email">>, PostVals),
    Password = proplists:get_value(<<"pass">>, PostVals),
    io:format("e ~p~n, p ~p~n", [Email, Password]),
    {cowboy_rest, Req1, State}.

allowed_methods(Req, State) ->  
    {[<<"POST">>], Req, State}.

content_types_provided(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, []}, hello_to_json}
    ], Req, State}.

login_to_json(Req, State) ->
    {jiffy:encode(State), Req, State}.
