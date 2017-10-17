-module(register_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).

%% Callback Callbacks
-export([register_from_json/2]).
-export([register_from_text/2]).

%% Helpes
-import(helper, [get_body/2, get_model/3, reply/3]).

%% Cowboy REST callbacks
init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}. 

content_types_provided(Req, State) ->
    {[
        {<<"text/plain">>, register_from_text},
        {<<"text/html">>, register_from_text}
    ], Req, State}.

content_types_accepted(Req, State) ->
    {[
        {<<"application/json">>, register_from_json}
    ], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:method(Req) of
        <<"GET">> -> {true, Req, State};
        <<"POST">> -> {false, Req, State}
    end.

register_from_json(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_urlencoded_body(Req),

    %% Check request body
    case get_body(Body, Req1) of
        {ok, Input, _Req} ->
            %% Validate body json and fields
            Model = [
                {<<"email">>, required, string, email, [non_empty,
                    fun(V) ->
                        validator:email(V)
                    end
                ]},
                {<<"pass">>, required, string, pass, [non_empty, 
                    fun(V) -> 
                        validator:min_length(6, V)
                    end
                ]},
                {<<"fname">>, required, string, pass, [non_empty]},
                {<<"lname">>, required, string, lname, [non_empty]}                
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

                    %% Perform Registration
                    case registration(Emodel, Req1) of
                        {ok, User, Req5} ->
                            {true, reply(200, User, Req5), State};
                        {error, Req6} ->
                            {false, Req6, State}
                    end

            end;

        {error, empty, Req2} -> 
            {false, Req2, State}

    end.

register_from_text(Req, State) ->
    case cowboy_session:get(<<"register">>, Req) of
        {undefined, Req1} ->
            {[], reply(400, <<"Token expired">>, Req1), State};
        {Register, Req1} ->
            erlang:display(Register),
            {jiffy:encode(Register), Req1, State}
    end.

%% Registration functions
registration(Emodel, Req) ->
    %% Auth middleware
    case middleware:allready_auth(Req) of
        {false, Req1} ->
            {ok, Data} = Emodel,
            % Email = maps:get(email, Data),
            % Pass = maps:get(pass, Data),
            % Fname = maps:get(fname, Data),
            % Lname = maps:get(lname, Data),
            % Token = ,
            case persist:check_user(pgdb, maps:get(email, Data)) of
                false -> 
                    Register = maps:put(token, random(), Data),
                    {ok, Req2} = cowboy_session:set(<<"register">>, Register, Req1),
                    {ok, Register, Req2};
                _ ->
                    {error, reply(400, <<"User already exists">>, Req1)}
            end;
            % case persist:get_user(pgdb, Email, pwd2hash(Pass), Fname, Lname) of
            %     none ->
            %         {error, reply(412, <<"These credentials do not match our records.">>, Req1)};
            %     {ok, User} ->
            %         {ok, Req2} = cowboy_session:set(<<"user">>, User, Req1),
            %         {ok, User, Req2}
            % end;
        {true, _User, Req3} -> {error, Req3}
    end.

random() ->
    base64:encode(crypto:strong_rand_bytes(64)).