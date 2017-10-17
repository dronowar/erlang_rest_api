# erlang_rest_api
Simple example Erlang Cowboy REST API service
## To start
```
make run-local
```
Install Postgres and create database "erl".

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

POST /login
Login
json body: {"email": "email@email.com", "pass": "123456"} 

POST /logout
Logout
```
