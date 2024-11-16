require 'rails_helper'

RSpec.describe "API V1 IncidentTypes", type: :request do
  let(:test_csv_path) { Rails.root.join('spec', 'fixtures', 'test_incident_types.csv') }
  let(:test_data) do
    [
      { "code" => "ABDUCT", "description" => "Abduction", "category" => "Crime" },
      { "code" => "BOMB", "description" => "Bombing", "category" => "Emergency" }
    ]
  end

  before(:all) do
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures'))
  end

  before(:each) do
    redis_double = stub_redis_connection
    test_data.each do |data|
      allow(redis_double).to receive(:get).with("incident_type:#{data['code']}")
        .and_return(data.to_json)
    end
    allow(redis_double).to receive(:keys).with("incident_type:*")
      .and_return(test_data.map { |d| "incident_type:#{d['code']}" })

    # Create and load test data
    CSV.open(test_csv_path, 'w') do |csv|
      csv << test_data.first.keys
      test_data.each { |row| csv << row.values }
    end

    ::V1::IncidentType.load_from_csv(test_csv_path)
  end

  after(:each) do
    File.delete(test_csv_path) if File.exist?(test_csv_path)
  end

  describe "GET /api/v1/incident_types" do
    it "returns all incident types" do
      get "/api/v1/incident_types"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).not_to be_empty
    end
  end

  describe "GET /api/v1/incident_types/:code" do
    context "when the code exists" do
      it "returns the incident type details" do
        existing_code = test_data.first["code"]
        get "/api/v1/incident_types/#{existing_code}"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("code" => existing_code)
      end
    end

    context "when the code does not exist" do
      it "returns a not found response" do
        get "/api/v1/incident_types/non_existent_code"
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("error" => "Incident type not found")
      end
    end
  end
end
