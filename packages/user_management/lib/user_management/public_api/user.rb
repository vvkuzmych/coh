class UserManagement::PublicApi::User < UserManagement::PublicApi::Base
  # Configure which model and DTO to use
  # Use string for model_class to avoid eager loading issues
  configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

  # Custom methods specific to User API

  # Get all users by account_id
  def self.get_all_by_account_id(account_id)
    where(account_id: account_id)
  end

  # Get a user by email
  def self.find_by_email(email)
    find_by(email: email)
  end

  # Get administrators (using scope)
  def self.administrators
    users = model_class.administrators
    wrap_collection(users)
  end

  # Get regular users (using scope)
  def self.regular_users
    users = model_class.regular_users
    wrap_collection(users)
  end

  # Get users by role
  def self.with_role(role)
    where(role: role)
  end

  # Count users by account
  def self.count_by_account(account_id)
    count_where(account_id: account_id)
  end

  # Pluck specific attributes for users by account_id
  # Returns raw values, not DTOs (for efficient queries)
  def self.pluck_by_account_id(account_id, *attributes)
    model_class.where(account_id: account_id).pluck(*attributes)
  end
end
