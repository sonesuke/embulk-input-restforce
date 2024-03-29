require 'time'
require 'digest'
require_relative 'object/object_wrapper'

module Embulk
  module Input

    class Restforce < InputPlugin
      Plugin.register_input("restforce", self)

      def self.transaction(config, &control)
        # configuration code:
        task = {
            "user_name" => config.param("user_name", :string), # string, required
            "password" => config.param("password", :string), # string, required
            "security_token" => config.param("security_token", :string), # string, required
            "client_id" => config.param("client_id", :string), # string, required
            "client_secret" => config.param("client_secret", :string), # string, required
            "sobject" => config.param("sobject", :string), # string, required
            "api" => config.param("api", :string, default: "45.0"),
            "from_date" => config.param("from_date", :string, default: nil),
            "skip_columns" => config.param("skip_columns", :array, default: []),
            "hashed_columns" => config.param("hashed_columns", :array, default: []),
            "columns" => config.param("columns", :array, default: []),
        }
        columns = task["columns"].size > 0 ? create_from_config(task) : create_from_profile(task)
        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)
        task_report = task_reports.first
        next_to_date = Time.parse(task_report[:to_date])
        next_config_diff = {from_date: next_to_date.to_s}
        return next_config_diff
      end

      def self.create_from_config(task)
        return task["columns"].map.with_index { |column, i| Column.new(i, column['name'], column['type'].to_sym) }
      end

      def self.create_from_profile(task)
        Embulk.logger.info "Query profile"
        wrapper = ObjectWrapper.new task["user_name"], task["password"], task["security_token"], task["client_id"], task["client_secret"], task["api"]
        fields = wrapper.get_profile(task["sobject"], Embulk.logger)
        if not task["skip_columns"].nil? then
          fields = filter_fields(fields, task["sobject"], task["skip_columns"])
        end
        fields.map.with_index { |field, i| Column.new(i, field[:name], field[:type]) }
      end

      def self.filter_fields(fields, object, skip_columns)
        skip_columns.each do | skip_column |
          if skip_column.has_key?("ignore") and skip_column["ignore"].count(object) > 0 then
            Embulk.logger.info "pattern '#{skip_column["pattern"]}' is ignored."
            next
          end
          fields = fields.select {|field| not /^#{skip_column["pattern"]}$/.match(field[:name])}
        end
        fields
      end

      # TODO
      # def self.guess(config)
      #   sample_records = [
      #     {"example"=>"a", "column"=>1, "value"=>0.1},
      #     {"example"=>"a", "column"=>2, "value"=>0.2},
      #   ]
      #   columns = Guess::SchemaGuess.from_hash_records(sample_records)
      #   return {"columns" => columns}
      # end

      def init
        # initialization code:
        @user_name = task["user_name"]
        @password = task["password"]
        @hashed_columns = task["hashed_columns"]
        @user_key = task["user_key"]
      end

      def run
        wrapper = ObjectWrapper.new task["user_name"], task["password"], task["security_token"], task["client_id"], task["client_secret"], task["api"]
        execution_at = Time.now
        search_criteria = task["from_date"].nil? ? {} : {:updated_after => Time.parse(task["from_date"]).strftime("%Y-%m-%dT%H:%M:%S%:z")}
        fields = schema.map {|column| column.name }
        rows = wrapper.query(task["sobject"], fields, search_criteria, Embulk.logger)

        rows.each do |row|
          result = schema.map { |column| evaluate_column(column, row, @hashed_columns, task["sobject"]) }
          page_builder.add(result)
        end
        page_builder.finish

        task_report = {to_date: execution_at}
        return task_report
      end

      def evaluate_column(column, row, hashed_columns, sobject)
        if not row.has_key?(column.name) or row[column.name].nil? then
          return nil
        end

        begin
          value = row[column.name]
          case column.type
          when :boolean then
            return value
          when :timestamp then
            return value.size > 10 ? Time.strptime(value, "%Y-%m-%dT%H:%M:%S.%L%z").to_i : Time.strptime(value, "%Y-%m-%d").to_i
          else
            hashed_columns.each do | hashed_column |
              if hashed_column.has_key?("ignore") and hashed_column["ignore"].count(sobject) > 0 then
                next
              end
              if /^#{hashed_column["pattern"]}$/.match(column.name) then
                return Digest::MD5.hexdigest(value)
              end
            end
            return value
          end
        rescue
          Embulk.logger.info "#{column.name}:#{row[column.name]} is relaced by null."
          return nil
        end
      end
    end
  end
end
