class UserManagement::User < ApplicationRecord
  # Set the correct table name (users table is in the main app database)
  self.table_name = "users"

  # Note: account_id and user_id foreign keys exist in database
  # But we access related data through GraphQL instead of ActiveRecord associations

  # Roles enum
  enum :role, {
    guest: 0,
    member: 1,
    admin: 2,
    super_admin: 3
  }, prefix: true

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Role-based scopes
  scope :administrators, -> { where(role: [ :admin, :super_admin ]) }
  scope :regular_users, -> { where(role: [ :guest, :member ]) }

  # Full name
  def full_name
    "#{first_name} #{last_name}"
  end

  # Role helper methods
  def administrator?
    role_admin? || role_super_admin?
  end

  def regular_user?
    role_guest? || role_member?
  end

  # Get account through GraphQL
  def account
    return @account if defined?(@account)
    @account = account_id ? fetch_account : nil
  end

  # Get documents through GraphQL (optionally filtered by status)
  def documents(status: nil)
    data = UserManagement::Services::GraphqlClient.get_documents(id, status: status)
    data.map { |doc| UserManagement::Responses::DocumentResponse.new(doc) }
  end

  # Get documents count through GraphQL
  def documents_count(status: nil)
    documents(status: status).size
  end

  # Get documents grouped by status
  def documents_by_status
    {
      uploaded: documents(status: "uploaded"),
      reviewed: documents(status: "reviewed"),
      signed: documents(status: "signed"),
      archived: documents(status: "archived")
    }
  end

  private

  def fetch_account
    data = UserManagement::Services::GraphqlClient.get_account(account_id)
    return nil unless data

    UserManagement::Responses::AccountResponse.new(data)
  end
end
