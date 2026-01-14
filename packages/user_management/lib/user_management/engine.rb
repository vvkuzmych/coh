module UserManagement
  class Engine < ::Rails::Engine
    isolate_namespace UserManagement

    config.autoload_paths << File.expand_path("../", __FILE__)

    initializer "user_management.load_services" do
      require_relative "services/graphql_client"
      require_relative "responses/account_response"
      require_relative "responses/document_response"
    end
  end
end
