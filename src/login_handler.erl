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
    % io:format("login~n"),
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
    {ok, Body, Req1} = cowboy_req:read_urlencoded_body(Req),
    Input = get_body(Body, Req1),
    % erlang:display(get_body(Body, Req1)),
    Model = [
        {<<"email">>, required, string, email, [non_empty]},
        {<<"pass">>, required, string, pass, [non_empty]}
    ],
    Emodel = get_model(Input, Model, Req1),
    erlang:display(Emodel),
    case Emodel of
        {error, Reason} ->
            reply(412, {Reason}, Req1);
        {ok, _} ->
            login(Emodel, Req1)       
    end,
        
    % {Session, _} = cowboy_session:get(<<"user">>, Req1),
    % erlang:display(Session),
            % Response = Req3
    
    % erlang:display(Emodel),
    % erlang:display(Req),
    % erlang:display(Req1),
    % erlang:display(Req2),
    % erlang:display("Session"),
    % erlang:display(Emodel),
    % io:format("Req0: ~p~n", [Req0]),
    % io:format("Emodel: ~p~n", [Emodel]),
    % {_, Req3} = login(Emodel, Req2),
    % Res = cowboy_session:get(<<"user">>, Req2),
    {true, Req1, State}.

login(Emodel, Req) ->
    case cowboy_session:get(<<"user">>, Req) of
        undefined ->
            {ok, Req1} = cowboy_session:set(<<"user">>, Emodel, Req);
        _ ->
            reply(400, <<"Allready auth">>, Req)
    end.
    % {ok, Req}.

get_body(Body, Req) ->
    case Body of 
        [{Input, true}] ->
            Input;
        [] ->
            reply(400, <<"Missing body">>, Req);
            % {ok, Resp} = reply(400, <<"Missing body">>, Req),
            % {false, Resp};
        _ ->
            reply(400, <<"Bad request">>, Req)
    end.

get_model(Input, Model, Req) ->
    % {ok, Req3} = reply(400, <<"Invalid json">>, Req),
    % {false, Req3}.
    % case Body of 
        % [{Input, true}] ->
            % io:format("Post: ~p~n", [Input]), 
            try jiffy:decode(Input, [return_maps]) of
                Data ->
            %         % Email = maps:get(<<"email">>, Data),
                    emodel:from_map(Data, #{}, Model)
            %         Req3 = reply(200, Data, Req),
            catch
                _:_ ->
                    % false
                    reply(400, <<"Invalid json">>, Req)
                    % {false, Req3};
            end.
        % [] ->
            % Req2 = reply(400, <<"Missing body">>, Req),
            % {false, Req2};
        % _ ->
            % Req2 = reply(400, <<"Bad request">>, Req),
            % {false, Req2}
    % end.

% reply(Code, Body, Req) ->
    % get_reply()    

reply(Code, Body, Req) ->
    cowboy_req:reply(Code, #{<<"content-type">> => <<"application/json">>}, jiffy:encode(Body), Req).
    % {ok, Resp}.
