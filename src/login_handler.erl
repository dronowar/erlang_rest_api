-module(login_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).

%% Callback Callbacks
-export([login_from_json/2]).

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}. 

content_types_accepted(Req, State) ->
    {[
        {<<"application/json">>, login_from_json}
    ], Req, State}.

resource_exists(Req, State) ->
  {false, Req, State}.

login_from_json(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_urlencoded_body(Req),

    %% Check request body
    case get_body(Body, Req1) of
        {ok, Input, _Req} ->
            %% Validate body json and fields
            Model = [
                {<<"email">>, required, string, email, [non_empty]},
                {<<"pass">>, required, string, pass, [non_empty]}
            ],
            Emodel = get_model(Input, Model, Req1),

            %% Check model result
            case Emodel of
                {error, Reason} ->
                    Req3 = reply(412, {Reason}, Req1),
                    {false, Req3, State};
                {error, empty, Req4} ->
                    {false, Req4, State};
                {ok, _} ->

                    %% Perform login
                    case login(Emodel, Req1) of
                        {ok, ReqUser} ->
                            {true, ReqUser, State};
                        {error, Req6} ->
                            {false, Req6, State}
                    end

            end;

        {error, empty, Req2} -> 
            {false, Req2, State}

    end.

login(Emodel, Req) ->
    {User, _} = cowboy_session:get(<<"user">>, Req),
    case User of
        undefined ->
            {ok, Req1} = cowboy_session:set(<<"user">>, Emodel, Req),
            {ok, Data} = Emodel,
            {ok, reply(200, Data, Req1)};
        _ ->
            {error, reply(400, <<"Allready auth">>, Req)}
    end.

get_body(Body, Req) ->
    case Body of 
        [{Input, true}] ->
            {ok, Input, Req};
        [] ->
            {error, empty, reply(400, <<"Missing body">>, Req)};
        _ ->
            {error, empty, reply(400, <<"Bad request">>, Req)}
    end.

get_model(Input, Model, Req) ->
            try jiffy:decode(Input, [return_maps]) of
                Data ->
                    emodel:from_map(Data, #{}, Model)
            catch
                _:_ ->
                    {error, empty, reply(400, <<"Invalid json">>, Req)}
            end.

reply(Code, Body, Req) ->
    cowboy_req:reply(Code, #{<<"content-type">> => <<"application/json">>}, jiffy:encode(Body), Req).