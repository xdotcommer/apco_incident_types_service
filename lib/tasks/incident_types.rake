# lib/tasks/incident_types.rake
namespace :incident_types do
  desc "Load incident types from CSV file"
  task load: :environment do
    file_path = Rails.root.join("data", "apco_common_incident_types_2.103.2-2019.csv")

    if File.exist?(file_path)
      count = V1::IncidentType.load_from_csv(file_path)
      puts "Successfully loaded #{count} incident types"

      puts "\nSample of loaded data:"
      V1::IncidentType.all_codes.take(5).each do |code|
        data = V1::IncidentType.find_by_code(code)
        puts "  #{code}: #{data["description"]}"
      end
    else
      puts "CSV file not found at: #{file_path}"
    end
  end

  desc "Clear all incident types from Redis"
  task clear: :environment do
    pattern = "#{V1::IncidentType.redis_namespace}:*"
    count = $redis.keys(pattern).count
    $redis.del(*$redis.keys(pattern)) if count > 0
    puts "Cleared #{count} incident types from Redis"
  end

  desc "Show current incident types in Redis"
  task show: :environment do
    codes = V1::IncidentType.all_codes
    puts "Found #{codes.count} incident types in Redis:"
    codes.each do |code|
      data = V1::IncidentType.find_by_code(code)
      puts "  #{code}: #{data["description"]}"
    end
  end
end
