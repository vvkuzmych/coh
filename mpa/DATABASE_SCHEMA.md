# Database Schema & Relationships

## Overview

The application uses a fully normalized hierarchical structure: **Account → User → Document**

Users are differentiated by **roles** (guest, member, admin, super_admin). See **[USER_ROLES.md](USER_ROLES.md)** for detailed role documentation.

**Note:** Documents belong to Users, and Users belong to Accounts. To access an account's documents, query through the user relationship (normalized design).

## Entity Relationship Diagram

```
┌──────────────────┐
│     Account      │
│──────────────────│
│ id               │◄─────┐
│ name             │      │
│ created_at       │      │ has_many
│ updated_at       │      │
└──────────────────┘      │
                          │
                    ┌─────┴──────────┐
                    │      User      │
                    │────────────────│
                    │ id             │◄─────┐
                    │ email          │      │
                    │ first_name     │      │
                    │ last_name      │      │
                    │ role           │      │
                    │ account_id     │      │ has_many
                    │ created_at     │      │
                    │ updated_at     │      │
                    └────────────────┘      │
                                            │
                                      ┌─────┴────────────────┐
                                      │     Document         │
                                      │──────────────────────│
                                      │ id                   │
                                      │ title                │
                                      │ content              │
                                      │ user_id              │
                                      │ total_documents      │
                                      │ storage_bytes        │
                                      │ created_at           │
                                      │ updated_at           │
                                      └──────────────────────┘
```

## Relationships

### Account
- **Has many** Users
- **Has many** Documents (through Users)
- Users are deleted when Account is deleted (`dependent: :destroy`)
- Documents are deleted when their User is deleted (cascade through User)

### User
- **Belongs to** Account (required)
- **Has many** Documents
- Documents are deleted when User is deleted (`dependent: :destroy`)

### Document
- **Belongs to** User (required)
- Can access Account through User (via `delegate`)

## Models

### Account Model

```ruby
# app/models/account.rb
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
```

**Attributes:**
- `name` (string, required, indexed)

**Methods:**
```ruby
account = Account.create!(name: "Acme Corporation")
account.users               # => Returns all users belonging to this account
account.users.count         # => Number of users
account.documents           # => Returns all documents through users (JOIN query)
account.documents_count     # => Total number of documents (through users)
account.total_storage_bytes # => Total storage in bytes across all documents
```

### User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  belongs_to :account
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
  scope :administrators, -> { where(role: [:admin, :super_admin]) }
  scope :regular_users, -> { where(role: [:guest, :member]) }
  
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
```

**Attributes:**
- `email` (string, required, unique, indexed)
- `first_name` (string, required)
- `last_name` (string, required)
- `role` (integer enum, default: 0 [guest], indexed)
  - `0` = guest
  - `1` = member
  - `2` = admin
  - `3` = super_admin
- `account_id` (foreign key, required, indexed)

**Methods:**
```ruby
user = User.create!(
  email: "john@example.com",
  first_name: "John",
  last_name: "Doe",
  account: account
)

user.account            # => Returns the associated Account
user.documents          # => Returns all documents belonging to this user
user.documents.count    # => Number of documents
```

### Document Model

```ruby
# app/models/document.rb
class Document < ApplicationRecord
  belongs_to :user
  
  # Delegate account access through user
  delegate :account, to: :user
  
  validates :title, presence: true
  validates :storage_bytes, numericality: { greater_than_or_equal_to: 0 }
  validates :total_documents, numericality: { greater_than_or_equal_to: 0 }
  
  # Calculate storage bytes from content before save
  before_save :calculate_storage_bytes
  
  private
  
  def calculate_storage_bytes
    self.storage_bytes = (content.to_s.bytesize + title.to_s.bytesize)
  end
end
```

**Attributes:**
- `title` (string, required, indexed)
- `content` (text, optional)
- `user_id` (foreign key, required, indexed)
- `total_documents` (integer, default: 0) - Page count or related document count
- `storage_bytes` (bigint, default: 0) - Size of document in bytes (auto-calculated)

**Methods:**
```ruby
document = Document.create!(
  title: "My Document",
  content: "Document content here...",
  user: user,
  total_documents: 5  # Optional: number of pages or related docs
)

# storage_bytes is automatically calculated from content + title

document.user              # => Returns the associated User
document.account           # => Returns the Account through User (delegated)
document.storage_bytes     # => Size in bytes (auto-calculated)
document.total_documents   # => Page count or related doc count
```

## Migrations

### Create Accounts

```ruby
class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false

      t.timestamps
    end
    
    add_index :accounts, :name
  end
end
```

### Create Users

```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end
end
```

### Create Documents

```ruby
class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.integer :total_documents, default: 0, null: false
      t.bigint :storage_bytes, default: 0, null: false

      t.timestamps
    end
    
    add_index :documents, :title
    add_index :documents, [:user_id, :created_at]
  end
end
```

### Add Role to Users

```ruby
class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_index :users, :role
  end
end
```

## Usage Examples

### Creating Records

```ruby
# Create an account with users and documents
account = Account.create!(name: "Acme Corp")

# Create super admin
super_admin = account.users.create!(
  email: "superadmin@acme.com",
  first_name: "Super",
  last_name: "Admin",
  role: :super_admin
)

# Create admin
admin = account.users.create!(
  email: "admin@acme.com",
  first_name: "Admin",
  last_name: "User",
  role: :admin
)

# Create member (regular user)
user1 = account.users.create!(
  email: "john@acme.com",
  first_name: "John",
  last_name: "Doe",
  role: :member
)

# Create guest (default role, can omit role parameter)
user2 = account.users.create!(
  email: "jane@acme.com",
  first_name: "Jane",
  last_name: "Smith"
  # role defaults to :guest
)

# Create documents
doc1 = user1.documents.create!(
  title: "Project Proposal",
  content: "This is the project proposal..."
)

doc2 = user1.documents.create!(
  title: "Meeting Notes",
  content: "Meeting notes from today..."
)
```

### Querying Records

```ruby
# Find account by name
account = Account.find_by(name: "Acme Corp")

# Get all users in an account
account.users
# => [#<User id: 1, email: "john@acme.com"...>, ...]

# Get all documents in an account (through users)
account.documents
# => Uses JOIN: SELECT documents.* FROM documents INNER JOIN users ON users.id = documents.user_id WHERE users.account_id = ?

# Find user by email
user = User.find_by(email: "john@acme.com")

# Get user's account
user.account
# => #<Account id: 1, name: "Acme Corp">

# Get user's documents
user.documents
# => [#<Document id: 1, title: "Project Proposal"...>, ...]

# Find document and traverse relationships
document = Document.find_by(title: "Project Proposal")
document.user
# => #<User id: 1, email: "john@acme.com">

document.user.account
# => #<Account id: 1, name: "Acme Corp">
```

### Counting Records

```ruby
# Count users per account
Account.joins(:users).group('accounts.id').count

# Count documents per user
User.joins(:documents).group('users.id').count

# Total documents in an account
account.documents.count
# or using the helper method
account.documents_count

# Total storage used by account
account.total_storage_bytes
# => 987654321 (bytes)

# Average document size in account
account.documents.average(:storage_bytes)

# Count users by role
User.group(:role).count
# => {"guest"=>5, "member"=>20, "admin"=>3, "super_admin"=>1}

# Count admins in account
account.users.administrators.count
```

### Role-Based Queries

```ruby
# Find all users with specific role
User.role_guest
User.role_member
User.role_admin
User.role_super_admin

# Find administrators (admins + super_admins)
User.administrators

# Find regular users (guests + members)
User.regular_users

# Check user role
user.role_admin?        # => true/false
user.administrator?     # => true if admin or super_admin
user.regular_user?      # => true if guest or member

# Get role as string
user.role               # => "guest", "member", "admin", or "super_admin"

# Update user role
user.role_admin!        # Change to admin and save
user.update!(role: :member)  # Update role

# Query users by role in account
account.users.role_admin
account.users.administrators
```

### Deleting Records (Cascade)

```ruby
# Deleting an account deletes all its users and their documents
account.destroy
# => Deletes: Account → All Users → All Documents

# Deleting a user deletes all their documents
user.destroy
# => Deletes: User → All Documents

# Deleting a document only deletes that document
document.destroy
# => Deletes: Just the Document
```

## Database Constraints

### Foreign Keys
- `users.account_id` → `accounts.id` (required)
- `documents.user_id` → `users.id` (required)

### Unique Constraints
- `users.email` (unique across all users)

### NOT NULL Constraints
- `accounts.name`
- `users.email`, `users.first_name`, `users.last_name`, `users.account_id`, `users.role`
- `documents.title`, `documents.user_id`, `documents.total_documents`, `documents.storage_bytes`

### Indexes
- `accounts.name` (for fast lookups)
- `users.email` (unique index)
- `users.account_id` (foreign key index, auto-created)
- `users.role` (for role-based queries)
- `documents.title` (for fast searches)
- `documents.user_id` (foreign key index, auto-created)
- `documents.[user_id, created_at]` (composite index for user's documents sorted by date)

## Document Storage & Metadata

### Accessing Account Through User

Documents belong to Users, and Users belong to Accounts. To access a document's account:

```ruby
document = Document.find(1)

# Through the user relationship
document.user.account

# Or use the delegated method (cleaner)
document.account  # delegates to user.account
```

### Querying Documents by Account

```ruby
# Get all documents in an account (uses JOIN)
account.documents
# SQL: SELECT documents.* FROM documents 
#      INNER JOIN users ON users.id = documents.user_id 
#      WHERE users.account_id = ?

# More efficient with eager loading
account.documents.includes(:user)
```

### Storage Bytes

The `storage_bytes` field automatically calculates the size of the document:
```ruby
document = Document.create!(
  title: "My Document",
  content: "Some content here...",
  user: user
)

# Automatically calculated before save
document.storage_bytes # => size in bytes of title + content
```

**Query by storage:**
```ruby
# Find large documents
Document.where("storage_bytes > ?", 1_000_000) # > 1MB

# Total storage per account
account.total_storage_bytes
# => 987654321

# Documents sorted by size
Document.order(storage_bytes: :desc)

# Storage statistics
account.documents.sum(:storage_bytes)      # Total
account.documents.average(:storage_bytes)  # Average
account.documents.maximum(:storage_bytes)  # Largest
```

### Total Documents Field

The `total_documents` field can be used for:
- Page count in multi-page documents
- Number of attachments
- Version count
- Related document count

```ruby
document = Document.create!(
  title: "Annual Report",
  content: "...",
  user: user,
  total_documents: 25 # 25 pages
)

# Query by page count
Document.where("total_documents > ?", 10) # > 10 pages
```

## Rails Console Examples

```ruby
# Setup test data
account = Account.create!(name: "Test Corp")
user = account.users.create!(
  email: "test@test.com",
  first_name: "Test",
  last_name: "User",
  role: :member
)
doc = user.documents.create!(
  title: "Test Document",
  content: "Lorem ipsum dolor sit amet..." * 100,
  total_documents: 5
)

# Check automatically calculated fields
doc.storage_bytes                  # => automatically calculated

# Traverse relationships
doc.user.account.name              # => "Test Corp"
doc.account.name                   # => "Test Corp" (delegated through user)

# Eager loading to avoid N+1 queries
Account.includes(users: :documents).find(account.id)

# Count total documents in account (through users JOIN)
account.documents.count
# Same as:
Document.joins(:user).where(users: { account_id: account.id }).count

# Storage analytics
account.total_storage_bytes        # => Total bytes used
account.documents.average(:storage_bytes).to_i  # => Average doc size
account.documents.order(storage_bytes: :desc).limit(10)  # => Top 10 largest
```

## Testing Examples

```ruby
# spec/models/account_spec.rb
RSpec.describe Account, type: :model do
  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:documents).through(:users) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
  
  describe 'cascade delete' do
    it 'deletes users and their documents when account is deleted' do
      account = Account.create!(name: "Test")
      user = account.users.create!(
        email: "test@test.com",
        first_name: "Test",
        last_name: "User"
      )
      document = user.documents.create!(
        title: "Test Doc",
        content: "Content"
      )
      
      expect { account.destroy }.to change(User, :count).by(-1)
                                 .and change(Document, :count).by(-1)
    end
  end
end

# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:account) }
    it { should have_many(:documents).dependent(:destroy) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end
end

# spec/models/document_spec.rb
RSpec.describe Document, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_numericality_of(:storage_bytes).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_documents).is_greater_than_or_equal_to(0) }
  end
  
  describe 'delegation' do
    it 'delegates account to user' do
      account = Account.create!(name: "Test")
      user = account.users.create!(
        email: "test@test.com",
        first_name: "Test",
        last_name: "User"
      )
      document = user.documents.create!(
        title: "Test Doc",
        content: "Content"
      )
      
      expect(document.account).to eq(user.account)
    end
  end
  
  describe 'callbacks' do
    it 'calculates storage_bytes before save' do
      document = create(:document, title: "Test", content: "Content")
      expected_bytes = "Test".bytesize + "Content".bytesize
      
      expect(document.storage_bytes).to eq(expected_bytes)
    end
  end
end
```

## Run Migrations

```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa
rails db:migrate
```

## Verify Schema

```bash
rails db:schema:dump
cat db/schema.rb
```

## Rollback (if needed)

```bash
# Rollback last migration
rails db:rollback

# Rollback specific number of migrations
rails db:rollback STEP=3

# Reset entire database
rails db:reset
```
