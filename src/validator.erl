-module(validator).

-export([min_length/2, email/1]).

regexp_match(Re, Bin) ->
    case re:run(Bin, Re) of
        {match, _} ->
            ok;
        nomatch ->
            {error, <<"not valid email">>}
    end.

email(Email) ->
    regexp_match("^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,}$", Email).

% login(Login) ->
%     regexp_match("^\\w+([.-]?\\w+)+$", Login).

min_length(MinLength, Bin) when byte_size(Bin) < MinLength ->
    {error, list_to_binary("min length: " ++ integer_to_list(MinLength))};
min_length(_, _) ->
    ok.