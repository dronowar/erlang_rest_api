APPNAME=erl
REBAR=`which rebar3 || echo ./rebar3`

all: deps compile

deps:
	@( $(REBAR) get-deps )

compile:
	@( $(REBAR) compile )

clean:
	@( $(REBAR) clean )

run:
	erl -config config/sys -pa ./ebin -pa ./deps/*/ebin -sname $(APPNAME)@localhost -s $(APPNAME)

run-local:
	erl -config config/sys -pa ./ebin -pa ./deps/*/ebin -sname $(APPNAME)@localhost -s $(APPNAME) -s sync

.PHONY: all, deps, compile
