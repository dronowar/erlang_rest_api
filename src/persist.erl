-module(persist).

-export([init_db/1]).

init_db(Pool) ->
    pgapp:squery(Pool, "
        DROP TABLE users;
        CREATE TABLE users (
            mail varchar(128) PRIMARY KEY,
            fname varchar(128),
            lname varchar(128)
        );
    ").