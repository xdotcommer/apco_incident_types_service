module Api
  module V1
    class CallTypesController < ApplicationController
      def show
        incident_type = ::V1::IncidentType.find_by_call_type(params[:type])
        if incident_type
          render json: incident_type
        else
          render json: { error: "No matching APCO code found" }, status: :not_found
        end
      end
    end
  end
end
