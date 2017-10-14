-module(login_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
%-export([resource_exists/2]).
-export([content_types_accepted/2]).
% -export([content_types_provided/2]).

%% Callback Callbacks
% -export([login_to_json/2]).
-export([login_from_json/2]).

init(Req, State) ->
    io:format("login~n"),
    % Email = proplists:get_value(<<"email">>, PostVals),
    % Password = proplists:get_value(<<"pass">>, PostVals),
    % Fields = 
        % try #{email := Email, pass := Password} = cowboy_req:match_qs([{email, notempty}, {pass, notempty}], Req),
        %     #{email => Email, pass => Password}
        % catch
        %     Error:Reason ->
        %         io:format("Error: ~p~n Reason: ~p~n", [Error, Reason])
                % cowboy_req:reply(400, [{<<"content-type">>, <<"application/json">>}], jiffy:encode(#{
                %     reason_code => 400,
                %     reason => list_to_binary("Reason")
                % }), Req)
        % end,
    % io:format("fields ~p~n", Fields),
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}. 

content_types_accepted(Req, State) ->
    {[
        {<<"application/json">>, login_from_json}
    ], Req, State}.

% content_types_provided(Req, State) -> 
%     {[
%         {<<"application/json">>, login_to_json}
%     ], Req, State}.

% login_to_json(Req, State) ->
%     {<<"Alladin">>, Req, State}.

login_from_json(Req, State) ->
    io:format("login_from_json~n"),
    {ok, Body, Req1} = cowboy_req:read_urlencoded_body(Req),
    io:format("Body: ~p~n", [Body]),
    case Body of
        [{PostVals, true}] ->
            io:format("Post: ~p~n", [PostVals]), 
            try jiffy:decode(PostVals, [return_maps]) of 
                Data ->
                    Email = maps:get(<<"email">>, Data),
                    io:format("Email: ~p~n", [Email]),
                    Req3 = reply(200, Data, Req1),
                    {true, Req3, State}
            catch
                _:_ -> 
                    Req3 = reply(400, <<"Invalid json">>, Req1),
                    {true, Req3, State}
            end;
        [] ->
            Req2 = reply(400, <<"Missing body">>, Req1),
            {true, Req2, State};
        _ ->
            Req2 = reply(400, <<"Bad request">>, Req1),
            {true, Req2, State}
    end.
    % {true, Req2, State}.
reply(Code, Body, Req) ->
    Req1 = cowboy_req:reply(Code, #{<<"content-type">> => <<"application/json">>}, jiffy:encode(Body), Req).