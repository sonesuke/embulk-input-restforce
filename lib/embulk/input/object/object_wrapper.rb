require 'restforce'

class ObjectWrapper

  def initialize(user_name, password, security_token, client_id, client_secret)
    @client = Restforce.new(username: user_name,
                            password: password,
                            security_token: security_token,
                            client_id: client_id,
                            client_secret: client_secret,
                            api_version: '45.0')
    @type_map = {
        "id" => :string,
        "boolean" => :boolean,
        "reference" => :string,
        "string" => :string,
        "double" => :double,
        "picklist" => :string,
        "textarea" => :string,
        "phone" => :string,
        "url" => :string,
        "int" => :long,
        "datetime" => :timestamp,
        "date" => :timestamp,
        "time" => :string,
        "currency" => :double,
        "email" => :string,
        "anyType" => :string,
        "percent" => :double,
        "multipicklist" => :string
    }
  end

  def query(sobject, fields, search_criteria, logger)
    query = "SELECT #{fields.join(',')} FROM #{sobject}"
    if search_criteria.has_key? :updated_after then
      query += " WHERE SystemModstamp >= #{search_criteria[:updated_after]}"
    end
    logger.info "query: #{query}"
    @client.query_all(query)
  end

  def get_profile(sobject, logger)
    descrption = @client.describe(sobject)
    descrption["fields"].each do |field|
      if not @type_map.has_key? field.type then
        logger.info "#{field.name} is ignored because it is type of #{field.type}"
      end
    end

    descrption["fields"]
        .select { |field| @type_map.has_key? field.type }
        .map { |field| {:name => field.name, :type => @type_map[field.type]} }
  end
end

