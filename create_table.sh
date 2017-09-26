#!/bin/bash

aws dynamodb create-table \
  --table-name recharge \
  --attribute-definitions AttributeName=UserId,AttributeType=S AttributeName=Year,AttributeType=S \
  --key-schema AttributeName=UserId,KeyType=HASH AttributeName=Year,KeyType=RANGE \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --endpoint-url http://localhost:8000
