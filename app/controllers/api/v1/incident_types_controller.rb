module Api
  module V1
    class IncidentTypesController < ApplicationController
      def index
        codes = ::V1::IncidentType.all_codes
        Rails.logger.debug "Found incident type codes: #{codes.inspect}"
        render json: codes
      end

      def show
        incident_type = ::V1::IncidentType.find_by_code(params[:code])
        if incident_type
          render json: incident_type
        else
          render json: { error: "Incident type not found" }, status: :not_found
        end
      end
    end
  end
end
