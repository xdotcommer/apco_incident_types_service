require 'rails_helper'

RSpec.describe V1::IncidentType do
  let(:test_csv_path) { Rails.root.join('spec', 'fixtures', 'test_incident_types.csv') }
  let(:test_data) do
    [
      { "code" => "ABDUCT", "description" => "Abduction", "category" => "Crime" },
      { "code" => "BOMB", "description" => "Bombing", "category" => "Emergency" }
    ]
  end

  let(:redis_double) { stub_redis_connection }

  before(:all) do
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures'))
  end

  before(:each) do
    # Set up Redis stub expectations for specific tests
    test_data.each do |data|
      allow(redis_double).to receive(:get).with("incident_type:#{data['code']}")
        .and_return(data.to_json)
    end
    allow(redis_double).to receive(:keys).with("incident_type:*")
      .and_return(test_data.map { |d| "incident_type:#{d['code']}" })

    # Create test CSV file
    CSV.open(test_csv_path, 'w') do |csv|
      csv << test_data.first.keys
      test_data.each { |row| csv << row.values }
    end
  end

  after(:each) do
    File.delete(test_csv_path) if File.exist?(test_csv_path)
  end

  describe '.load_from_csv' do
    context 'when the file exists' do
      it 'loads incident types into Redis cache' do
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
            csv << [ nil, 'Invalid', 'Test' ]  # Row with no code
          end
        end

        it 'skips rows without codes' do
          count = described_class.load_from_csv(test_csv_path)
          expect(count).to eq(1)

          codes = described_class.all_codes
          puts "Found codes: #{codes.inspect}"
          expect(codes).to contain_exactly(test_data.first['code'])
        end
      end
    end
  end

  describe '.all_codes' do
    before { described_class.load_from_csv(test_csv_path) }

    it 'returns all incident type codes' do
      codes = described_class.all_codes
      puts "Found codes: #{codes.inspect}"
      expect(codes).to match_array(test_data.map { |d| d['code'] })
    end

    context 'when cache is empty' do
      before { $redis.flushdb }

      it 'returns an empty array' do
        expect(described_class.all_codes).to be_empty
      end
    end
  end
end
