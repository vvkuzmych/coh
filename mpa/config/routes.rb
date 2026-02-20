Rails.application.routes.draw do
  # Swagger API Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount modular engines
  mount UserManagement::Engine, at: "/user_management"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # API routes (JSON)
  namespace :api do
    # API v1
    namespace :v1 do
      resources :documents, only: [:index, :show]
    end
    
    # Redirect /api/documents to /api/v1/documents (backwards compatibility)
    resources :documents, only: [:index, :show], controller: 'v1/documents'
  end

  # Search routes (OpenSearch integration)
  get "search", to: "search#index", as: :search_page
  get "search/results", to: "search#search", as: :search
  
  # Document pages (React/TypeScript)
  resources :documents, only: [:index, :show]

  # TypeScript demo page
  get "typescript-demo", to: "typescript_demo#index", as: :typescript_demo

  # Defines the root path route ("/")
  root "welcome#index"
end
