class UserManagement::User < ApplicationRecord
  # Set the correct table name (users table is in the main app database)
  self.table_name = "users"

  belongs_to :account, optional: true
  has_many :documents, class_name: "::Document", foreign_key: "user_id", dependent: :destroy

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
end
