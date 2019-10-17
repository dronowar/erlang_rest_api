#!/bin/sh
curl -b cookiejar -i -H "Content-Type: application/json" -X POST -d '{"email":"xyz","password":"xyz"}' http://localhost:8080/logout
echo
