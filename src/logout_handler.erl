-module(logout_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).

%% Callback Callbacks
-export([logout_from_json/2]).

%% Helpes
-import(helper, [reply/3]).

%% Cowboy REST callbacks
init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}. 

content_types_accepted(Req, State) ->
    {[
        {<<"application/json">>, logout_from_json}
    ], Req, State}.

resource_exists(Req, State) ->
  {false, Req, State}.

logout_from_json(Req, State) ->
    case logout(Req) of
        {ok, Req1} ->
            {true, Req1, State};
        {error, Req2} ->
            {false, Req2, State}
    end.

%% Logout functions
logout(Req) ->
    {User, _} = cowboy_session:get(<<"user">>, Req),
    case User of
        undefined ->
            {error, reply(400, <<"Allready logout">>, Req)};
        User ->
            {ok, Req1} = cowboy_session:expire(Req),
            {ok, Req1}
    end.