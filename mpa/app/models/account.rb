class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :documents, through: :users

  validates :name, presence: true

  # Get total storage used by all documents in this account
  def total_storage_bytes
    documents.sum(:storage_bytes)
  end

  # Get total number of documents in this account
  def documents_count
    documents.count
  end
end
