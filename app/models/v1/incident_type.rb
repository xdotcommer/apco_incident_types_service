# app/models/v1/incident_type.rb
module V1
  class IncidentType
    VERSION = "V1:"

    def self.cache_key(code)
      "#{VERSION}#{code}"
    end

    def self.load_from_csv(file_path)
      unless File.exist?(file_path)
        Rails.logger.warn "CSV file not found: #{file_path}"
        return 0
      end

      loaded_count = 0
      CSV.foreach(file_path, headers: true) do |row|
        next if row["code"].blank?

        key = cache_key(row["code"])
        Rails.cache.write(key, row.to_h)
        loaded_count += 1
      end

      loaded_count
    end

    def self.all_codes
      memory_store = Rails.cache.instance_variable_get(:@data)
      return [] unless memory_store

      memory_store.keys
                 .select { |k| k.start_with?(VERSION) }
                 .map { |key| key.sub(VERSION, "") }
    end

    def self.find_by_code(code)
      Rails.cache.read(cache_key(code))
    end

    def self.find_by_call_type(type)
      self.find_by_code(::AiCodeMapper.call_type_to_apco_code(type))
    end

    def cache_key(code)
      self.class.cache_key(code)
    end
  end
end
