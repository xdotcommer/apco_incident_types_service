require 'rails_helper'
require 'redis'

RSpec.describe "API V1 Status", type: :request do
  describe "GET /api/v1/status" do
    let(:headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    context "when Redis is connected" do
      let(:redis_mock) { instance_double(Redis) }

      before do
        allow(redis_mock).to receive(:ping).and_return("PONG")
        allow(Redis).to receive(:new).and_return(redis_mock)
      end

      it "returns a successful response with Redis connected" do
        get "/api/v1/status", headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq("status" => "ok", "redis" => "connected")
      end
    end

    context "when Redis is not connected" do
      let(:redis_mock) { instance_double(Redis) }

      before do
        allow(redis_mock).to receive(:ping).and_raise(Redis::CannotConnectError)
        allow(Redis).to receive(:new).and_return(redis_mock)
      end

      it "returns a service unavailable response with an error message" do
        get "/api/v1/status", headers: headers

        expect(response).to have_http_status(:service_unavailable)
        expect(JSON.parse(response.body)).to eq("error" => "Redis is not connected")
      end
    end
  end
end
