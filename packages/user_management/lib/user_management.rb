require "user_management/version"
require "user_management/engine"

module UserManagement # Define namespaces
  module Dto
  end

  module PublicApi
  end

  module Services
  end

  module Responses
  end
end

# Require files after module definitions
require "user_management/dto/base"
require "user_management/dto/user"
require "user_management/public_api/base"
require "user_management/public_api/user"
require "user_management/services/graphql_client"
require "user_management/responses/account_response"
require "user_management/responses/document_response"
