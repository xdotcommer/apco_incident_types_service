# spec/requests/api/v1/call_types_controller_spec.rb
require 'rails_helper'

RSpec.describe "API V1 CallTypes", type: :request do
  let(:test_data) do
    {
      "code" => "FIRE",
      "description" => "Fire",
      "category" => "Emergency"
    }
  end

  describe "GET /api/v1/call_types/:type" do
    context "when the call type maps to a valid APCO code" do
      it "returns the incident type details" do
        # Mock both necessary methods with correct class name
        expect(AiCodeMapper).to receive(:call_type_to_apco_code)
          .with('house_fire')
          .and_return('FIRE')
          .at_least(:once)

        expect(::V1::IncidentType).to receive(:find_by_code)
          .with('FIRE')
          .and_return(test_data)
          .at_least(:once)

        get "/api/v1/call_types/house_fire"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(test_data)
      end
    end

    context "when the call type doesn't map to a valid APCO code" do
      it "returns a not found response" do
        expect(AiCodeMapper).to receive(:call_type_to_apco_code)
          .with('house_fire')
          .and_return('FIRE')

        expect(::V1::IncidentType).to receive(:find_by_code)
          .with('FIRE')
          .and_return(nil)

        get "/api/v1/call_types/house_fire"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("error" => "No matching APCO code found")
      end
    end
  end
end
