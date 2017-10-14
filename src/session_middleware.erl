-module(session_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
    % SessionID = integer_to_list(rand:uniform(1000000)),
    % Req0 = cowboy_req:set_resp_cookie(<<"sessionid">>, SessionID, Req, #{path => <<"/">>}),
    % #{sessionid := CSessionID} = cowboy_req:match_cookies([{sessionid, [], <<>>}], Req0),
    % io:format("cookies: ~p~n", [CSessionID]),

    {ok, Req1} = cowboy_session:touch(Req),
    % {Value, Req2} = cowboy_session:get(<<"user_id">>, Req1),
    % io:format("session value: ~p~n", [Value]),

    {ok, Req1, Env}.
