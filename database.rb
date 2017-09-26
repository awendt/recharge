class Database

  include Singleton

  HASH_KEY = 'UserId'.freeze
  RANGE_KEY = 'Year'.freeze
  TABLE_NAME = 'recharge'.freeze

  def initialize
    client_opts = if ENV['DYNAMODB_URL']
      { endpoint: ENV['DYNAMODB_URL'], region: 'irrelevant' }
    else
      {}
    end
    @ddb = ::Aws::DynamoDB::Client.new(client_opts)
  end

  def put(id:, year:, vacation: )
    @ddb.put_item(item: key(id, year).merge(vacation: vacation), table_name: TABLE_NAME)
  end

  def get(id:, year:)
    @ddb.get_item(key: key(id, year), table_name: TABLE_NAME).item
  end

  def get_all(id:)
    condition = "#{HASH_KEY} = :id"
    attribute_values = {":id" => id}
    @ddb.query(key_condition_expression: condition, expression_attribute_values: attribute_values, table_name: TABLE_NAME)
  end

  private

  def key(id, year)
    { HASH_KEY => id, RANGE_KEY => year.to_s }
  end

end
