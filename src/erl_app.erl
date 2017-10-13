-module(erl_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([         
		{'_', [{"/", hello_handler, []}]}     
	]),     
	{ok, _} = cowboy:start_clear(my_http_listener,
		[{port, 8080}],
		#{env => #{dispatch => Dispatch}, 
		middlewares => [cowboy_router, session_middleware, cowboy_handler]
	}),
    erl_sup:start_link().

stop(_State) ->
    ok.
