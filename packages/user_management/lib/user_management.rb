require "user_management/version"
require "user_management/engine"

module UserManagement
  # Define namespaces for Dto and PublicApi
  module Dto
  end
  
  module PublicApi
  end
end

# Require files after module definitions
require "user_management/dto/base"
require "user_management/dto/user"
require "user_management/public_api/base"
require "user_management/public_api/user"
