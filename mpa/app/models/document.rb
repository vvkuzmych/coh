class Document < ApplicationRecord
  # Note: user_id foreign key exists, but we access User through PublicApi
  # No direct association to UserManagement::User (engine model)

  # Document status enum
  enum :status, {
    uploaded: 0,
    reviewed: 1,
    signed: 2,
    archived: 3
  }, prefix: true

  validates :title, presence: true
  validates :user_id, presence: true
  validates :storage_bytes, numericality: { greater_than_or_equal_to: 0 }

  # Status-based scopes
  scope :by_status, ->(status) { where(status: status) }

  # Calculate storage bytes from content before save
  before_save :calculate_storage_bytes

  # Get user for this document (returns DTO)
  def user
    return @user if defined?(@user)
    @user = UserManagement::PublicApi::User.find(user_id)
  end

  # Get account for this document (through user)
  def account
    user&.account_id ? Account.find_by(id: user.account_id) : nil
  end

  private

  def calculate_storage_bytes
    self.storage_bytes = (content.to_s.bytesize + title.to_s.bytesize)
  end
end
