-module(middleware).

-export([auth/2]).

-import(helper, [reply/3]).

auth(Emodel, Req) ->
    case cowboy_session:get(<<"user">>, Req) of
        {undefined, _} ->
            {true, Req};
        {_, _} ->
            {false, reply(400, <<"Allready auth">>, Req)}
    end.
