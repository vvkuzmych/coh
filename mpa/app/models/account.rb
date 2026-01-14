class Account < ApplicationRecord
  # Note: Users are managed by the user_management engine
  # We access them through the PublicApi, not through direct associations

  validates :name, presence: true

  # Get all users for this account (returns DTOs)
  def users
    UserManagement::PublicApi::User.get_all_by_account_id(id)
  end

  # Get all documents through users (using PublicApi)
  def documents
    user_ids = UserManagement::PublicApi::User.pluck_by_account_id(id, :id)
    Document.where(user_id: user_ids)
  end

  # Get total storage used by all documents in this account
  def total_storage_bytes
    documents.sum(:storage_bytes)
  end

  # Get total number of documents in this account
  def documents_count
    documents.count
  end

  # Get user count for this account
  def users_count
    UserManagement::PublicApi::User.count_by_account(id)
  end
end
