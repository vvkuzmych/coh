class UserManagement::Dto::User < UserManagement::Dto::Base
  # Define which attributes and methods to read from the User model
  dto_attribute :id
  dto_attribute :email
  dto_attribute :first_name
  dto_attribute :last_name
  dto_attribute :account_id
  dto_attribute :role
  dto_attribute :created_at
  dto_attribute :updated_at

  # Model methods (computed attributes)
  dto_attribute :full_name
  dto_attribute :administrator?
  dto_attribute :regular_user?
end
