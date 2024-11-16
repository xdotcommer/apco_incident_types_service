module Api
  module V1
    class StatusController < ApplicationController
      def index
        if redis_connected?
          render json: { status: "ok", redis: "connected" }
        else
          render json: { error: "Redis is not connected" }, status: :service_unavailable
        end
      end

      private

      def redis_connected?
        Redis.new.ping == "PONG"
      rescue Redis::CannotConnectError
        false
      end
    end
  end
end
