# spec/models/v1/incident_type_spec.rb
require 'rails_helper'

RSpec.describe V1::IncidentType do
  let(:test_csv_path) { Rails.root.join('spec', 'fixtures', 'test_incident_types.csv') }
  let(:test_data) do
    [
      { "code" => "ABDUCT", "description" => "Abduction", "category" => "Crime" },
      { "code" => "BOMB", "description" => "Bombing", "category" => "Emergency" }
    ]
  end

  before(:each) do
    Rails.cache.clear

    # Create test CSV file
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures'))
    CSV.open(test_csv_path, 'w') do |csv|
      csv << test_data.first.keys
      test_data.each { |row| csv << row.values }
    end
  end

  after(:each) do
    File.delete(test_csv_path) if File.exist?(test_csv_path)
  end

  describe '.load_from_csv' do
    it 'loads incident types into cache' do
      count = described_class.load_from_csv(test_csv_path)
      expect(count).to eq(test_data.length)

      test_data.each do |data|
        cached = described_class.find_by_code(data['code'])
        expect(cached).to eq(data)
      end
    end

    context 'when a row is missing a code' do
      before do
        CSV.open(test_csv_path, 'w') do |csv|
          csv << test_data.first.keys
          csv << test_data.first.values
          csv << [ nil, 'Invalid', 'Test' ]
        end
      end

      it 'skips rows without codes' do
        count = described_class.load_from_csv(test_csv_path)
        expect(count).to eq(1)

        codes = described_class.all_codes
        expect(codes).to contain_exactly(test_data.first['code'])
      end
    end
  end

  describe '.all_codes' do
    before do
      described_class.load_from_csv(test_csv_path)
    end

    it 'returns all incident type codes' do
      codes = described_class.all_codes
      expect(codes).to match_array(test_data.map { |d| d['code'] })
    end

    context 'when cache is empty' do
      before { Rails.cache.clear }

      it 'returns an empty array' do
        expect(described_class.all_codes).to be_empty
      end
    end
  end
end
