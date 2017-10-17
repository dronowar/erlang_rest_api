-module(middleware).

-export([allready_auth/1, auth/1]).

-import(helper, [reply/3]).

auth(Req) ->
    case cowboy_session:get(<<"user">>, Req) of
        {undefined, Req1} ->
            {false, Req1};
        {User, Req1} ->
            {true, User, Req}
    end.

allready_auth(Req) ->
    case auth(Req) of
        {true, User, Req} ->
            {true, User, reply(400, <<"Allready auth">>, Req)};
        {false, Req} ->
            {false, Req}
    end.