require 'rails_helper'

RSpec.describe "Rails Health Check", type: :request do
  describe "GET /up" do
    it "returns a 200 OK status" do
      get rails_health_check_path

      expect(response).to have_http_status(:ok)
    end
  end
end
