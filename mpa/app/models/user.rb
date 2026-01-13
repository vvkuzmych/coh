class User < ApplicationRecord
  belongs_to :account, optional: true
  has_many :documents, dependent: :destroy

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

  # Role helper methods
  def administrator?
    admin? || super_admin?
  end

  def regular_user?
    guest? || member?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
