-module(session_cowboy_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
    {ok, Req1} = cowboy_session:touch(Req),
    {ok, Req1, Env}.
