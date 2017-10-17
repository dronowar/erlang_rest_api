-module(login_handler).
-behavior(cowboy_rest).

%% REST Callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).

%% Callback Callbacks
-export([login_from_json/2]).

%% Helpes
-import(helper, [get_body/2, get_model/3, reply/3, pwd2hash/1]).

%% Cowboy REST callbacks
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
                {<<"email">>, required, string, email, [non_empty,
                    fun(V) ->
                        validator:email(V)
                    end
                ]},
                {<<"pass">>, required, string, pass, [non_empty, 
                    fun(V) -> 
                        validator:min_length(6, V)
                    end
                ]}
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
                        {ok, User, Req5} ->
                            {true, reply(200, User, Req5), State};
                        {error, Req6} ->
                            {false, Req6, State}
                    end

            end;

        {error, empty, Req2} -> 
            {false, Req2, State}

    end.

%% Login functions
login(Emodel, Req) ->
    %% Auth middleware
    case middleware:allready_auth(Req) of
        {false, Req1} ->
            {ok, Data} = Emodel,
            Email = maps:get(email, Data),
            Pass = maps:get(pass, Data),
            case persist:get_user(pgdb, Email, pwd2hash(Pass)) of
                none ->
                    {error, reply(412, <<"These credentials do not match our records.">>, Req1)};
                {ok, User} ->
                    {ok, Req2} = cowboy_session:set(<<"user">>, User, Req1),
                    {ok, User, Req2}
            end;
        {true, _User, Req3} -> {error, Req3}
    end.