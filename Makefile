APPNAME=erl
REBAR=`which rebar || echo ./rebar`

all: deps compile

deps:
	@( $(REBAR) get-deps )

compile:
	@( $(REBAR) compile )

clean:
	@( $(REBAR) clean )

run:
	erl -pa ./ebin -pa ./deps/*/ebin -sname $(APPNAME)@localhost -s $(APPNAME)

run-local:
	erl -pa ./ebin -pa ./deps/*/ebin -sname $(APPNAME)@localhost -s $(APPNAME) -s sync

.PHONY: all, deps, compile
