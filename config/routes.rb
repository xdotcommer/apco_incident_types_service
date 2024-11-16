Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check, defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      get "status", to: "status#index"
      get "incident_types", to: "incident_types#index"
      get "incident_types/:code", to: "incident_types#show"
      get "call_types/:type", to: "call_types#show"
    end
  end
end
