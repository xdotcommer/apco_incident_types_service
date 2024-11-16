# app/models/v1/incident_type.rb
module V1
  class IncidentType
    def self.redis_namespace
      "V1"
    end

    def self.load_from_csv(file_path)
      unless File.exist?(file_path)
        Rails.logger.warn "CSV file not found: #{file_path}"
        return 0
      end

      loaded_count = 0
      CSV.foreach(file_path, headers: true) do |row|
        code = row["code"]
        next unless code

        key = "#{redis_namespace}:#{code}"
        $redis.set(key, row.to_h.to_json)
        loaded_count += 1
      end

      Rails.logger.info "Loaded #{loaded_count} records into Redis"
      loaded_count
    end

    def self.all_codes
      keys = $redis.keys("#{redis_namespace}:*")
      keys.map { |key| key.split(":").last }
    end

    def self.find_by_code(code)
      data = $redis.get("#{redis_namespace}:#{code}")
      data ? JSON.parse(data) : nil
    end

    def self.find_by_call_type(type)
      self.find_by_code(::AiCodeMapper.call_type_to_apco_code(type))
    end
  end
end
