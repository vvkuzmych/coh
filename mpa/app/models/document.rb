class Document < ApplicationRecord
  belongs_to :user

  # Delegate account access through user
  delegate :account, to: :user

  validates :title, presence: true
  validates :storage_bytes, numericality: { greater_than_or_equal_to: 0 }

  # Calculate storage bytes from content before save
  before_save :calculate_storage_bytes

  private

  def calculate_storage_bytes
    self.storage_bytes = (content.to_s.bytesize + title.to_s.bytesize)
  end
end
