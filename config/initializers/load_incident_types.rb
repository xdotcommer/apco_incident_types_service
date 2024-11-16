Rails.application.config.after_initialize do
  if defined?(Rails::Server) || defined?(Rails::Console)
    puts "\n== Loading APCO Incident Types =="

    file_path = Rails.root.join("data", "apco_common_incident_types_2.103.2-2019.csv")

    if File.exist?(file_path)
      puts "Loading from: #{file_path}"
      count = ::V1::IncidentType.load_from_csv(file_path)
      puts "Successfully loaded #{count} incident types into Redis"
      puts "Sample of loaded data:"
      ::V1::IncidentType.all_codes.take(5).each do |code|
        puts "  - #{code}"
      end
    else
      puts "ERROR: CSV file not found at: #{file_path}"
      puts "Current directory: #{Rails.root}"
      puts "Available files in data/: #{Dir[Rails.root.join("data", "*")]}"
    end

    puts "=============================\n\n"
  end
end
