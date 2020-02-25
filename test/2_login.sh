#!/bin/sh
curl -c cookiejar -i -H "Content-Type: application/json" -X POST -d '{"email":"x@xyz.com","pass":"xyzXYZ"}' http://localhost:8080/login
echo
