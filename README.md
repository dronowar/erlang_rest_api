# Erlang REST API example
Simple example Erlang Cowboy REST API service
- Cowboy 2.0
- Cowboy sessions (fork)
- Emodel (validate user input)
- pgapp (poolboy and epgsql)
- sync (hotreload)
## To start

Install rebar  - (e.g. apt-get install rebar or yum rebar)

Then run
```
make
make run-local
```
Install Postgres and create database and postgres user.

Edit config /config/sys.config to connect db

init db in console:
```
persist:init_db(pgdb).
```
## To use
Url for API http://localhost:8080

content-type: application/json
```
GET /
Hello message

POST /register
Register new user
json body: {
  "email":"Anakin@darkside.com",
  "pass":"123456",
  "fname": "Dart",
  "lname": "Vader"
}

GET /register?token=EX9dNvZebWsKDwGlnUS06DajIwJMhjqCB1hkNvwnEtVHqehqoPvz7E8ULz1qhwTP
Complete registration

POST /login
Login
json body: {"email": "email@email.com", "pass": "123456"} 

POST /logout
Logout
```
