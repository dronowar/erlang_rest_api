#!/bin/sh
# email must be a properly formatted email address a@b.c
# password must be at least 6 chars
# first we request an account
OUTPUT=`curl -s -c cookiejar -i -H "Content-Type: application/json" -X POST -d '{"email":"x@xyz.com","fname":"Firstname","lname":"Lastname","pass":"xyzXYZ"}' http://localhost:8080/register`
echo $OUTPUT
TOKEN=`echo "${OUTPUT}" | grep 'token' | awk -F ',' {'print $1'} | awk -F ':' {'print $2'} | tr -d '"'`
echo "TOKEN:${TOKEN}"
# then we lock it in, eddie
curl -b cookiejar -i -H "Content-Type: application/json" -X GET http://localhost:8080/register?token=$TOKEN
echo
