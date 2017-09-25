require 'aws-sdk'
require 'pp'

ddb = Aws::DynamoDB::Client.new(endpoint: ENV["DYNAMODB_URL"])

pp ddb.create_table({
  attribute_definitions: [
    {
      attribute_name: "UserId",
      attribute_type: "S",
    },
    {
      attribute_name: "Year",
      attribute_type: "S",
    },
  ],
  key_schema: [
    {
      attribute_name: "UserId",
      key_type: "HASH",
    },
    {
      attribute_name: "Year",
      key_type: "RANGE",
    },
  ],
  provisioned_throughput: {
    read_capacity_units: 5,
    write_capacity_units: 5,
  },
  table_name: "recharge",
}).to_h

# aws dynamodb create-table --table-name recharge --attribute-definitions AttributeName=UserId,AttributeType=S AttributeName=Year,AttributeType=S --key-schema AttributeName=UserId,KeyType=HASH AttributeName=Year,KeyType=RANGE --endpoint-url http://localhost:8000