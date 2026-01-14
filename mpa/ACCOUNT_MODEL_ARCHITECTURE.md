# Account Model Architecture

## Overview

The `Account` model demonstrates proper integration with the `user_management` engine using the PublicApi pattern instead of direct ActiveRecord associations.

## Architecture Principles

### ❌ What We DON'T Do

```ruby
# BAD: Direct ActiveRecord associations to engine models
class Account < ApplicationRecord
  has_many :users, dependent: :destroy  # ❌ Direct coupling to engine
  has_many :documents, through: :users  # ❌ Won't work with engine
  
  def documents
    UserManagement::User.where(account_id: id) # ❌ Direct model access
  end
end
```

**Problems:**
- Tight coupling to internal engine models
- Bypasses DTO layer (security risk)
- Breaks encapsulation
- Engine changes can break the main app

### ✅ What We DO

```ruby
# GOOD: Use PublicApi for all engine interactions
class Account < ApplicationRecord
  validates :name, presence: true
  
  # Access users through PublicApi (returns DTOs)
  def users
    UserManagement::PublicApi::User.get_all_by_account_id(id)
  end
  
  # Access user data through PublicApi
  def documents
    user_ids = UserManagement::PublicApi::User.pluck_by_account_id(id, :id)
    Document.where(user_id: user_ids)
  end
  
  def users_count
    UserManagement::PublicApi::User.count_by_account(id)
  end
end
```

**Benefits:**
- Clean separation of concerns
- All data comes through DTOs (secure)
- Engine can change internal implementation without breaking the app
- Clear API boundaries

## Implementation Details

### 1. Accessing Users

**Method:** `account.users`

```ruby
def users
  UserManagement::PublicApi::User.get_all_by_account_id(id)
end
```

**Returns:** Array of `UserManagement::Dto::User` objects

**Example:**
```ruby
account = Account.first
users = account.users  # Returns DTOs, not ActiveRecord models

users.each do |user_dto|
  puts user_dto.email
  puts user_dto.full_name
  puts "Admin" if user_dto.administrator?
end
```

### 2. Accessing User Data Efficiently

**Method:** `account.documents`

```ruby
def documents
  user_ids = UserManagement::PublicApi::User.pluck_by_account_id(id, :id)
  Document.where(user_id: user_ids)
end
```

**Why pluck?** 
- We only need user IDs, not full user objects
- `pluck` returns raw values (efficient)
- No need to instantiate DTOs when we just need IDs

**Returns:** ActiveRecord relation of `Document` objects

### 3. Counting Users

**Method:** `account.users_count`

```ruby
def users_count
  UserManagement::PublicApi::User.count_by_account(id)
end
```

**Returns:** Integer (count of users)

**Why a separate method?**
- More efficient than `account.users.count` (no DTOs created)
- Runs a single SQL COUNT query
- Semantic clarity

### 4. Document Statistics

**Methods:** `total_storage_bytes`, `documents_count`

```ruby
def total_storage_bytes
  documents.sum(:storage_bytes)
end

def documents_count
  documents.count
end
```

**These are fine because:**
- They operate on `Document` models (not engine models)
- They use standard ActiveRecord queries
- They leverage the `documents` method which uses PublicApi

## PublicApi Methods Used

### From `UserManagement::PublicApi::User`

| Method | Purpose | Returns |
|--------|---------|---------|
| `get_all_by_account_id(account_id)` | Get all users for an account | Array of DTOs |
| `count_by_account(account_id)` | Count users for an account | Integer |
| `pluck_by_account_id(account_id, *attrs)` | Pluck specific attributes | Array of raw values |

## Usage Examples

### Example 1: List All Users in Account

```ruby
account = Account.find(1)

account.users.each do |user|
  puts "#{user.full_name} (#{user.email})"
  puts "  Role: #{user.role}"
  puts "  Admin: #{user.administrator?}"
end
```

### Example 2: Get Account Statistics

```ruby
account = Account.find(1)

puts "Account: #{account.name}"
puts "Users: #{account.users_count}"
puts "Documents: #{account.documents_count}"
puts "Storage: #{account.total_storage_bytes / 1024} KB"
```

### Example 3: Find Documents for Account

```ruby
account = Account.find(1)

account.documents.each do |doc|
  puts "#{doc.title} (#{doc.storage_bytes} bytes)"
end
```

### Example 4: Complex Query

```ruby
account = Account.find(1)

# Get all admin users for this account
admin_users = account.users.select(&:administrator?)

# Get documents created by admins
admin_user_ids = UserManagement::PublicApi::User
  .where(account_id: account.id, role: [:admin, :super_admin])
  .map(&:id)

admin_documents = Document.where(user_id: admin_user_ids)
```

## Testing

All methods have been tested and work correctly:

✅ `account.users` returns DTOs via PublicApi  
✅ `account.documents` uses PublicApi (no direct model access)  
✅ `account.users_count` returns correct count  
✅ `account.total_storage_bytes` calculates correctly  
✅ `account.documents_count` returns correct count  
✅ No direct association with User model  

## Benefits of This Architecture

### 1. **Encapsulation**
The main app doesn't know or care about the internal structure of the `user_management` engine.

### 2. **Security**
All user data passes through DTOs, which only expose what's explicitly defined.

### 3. **Flexibility**
The engine can change its internal implementation without breaking the main app.

### 4. **Testability**
Easy to mock PublicApi methods in tests without dealing with ActiveRecord associations.

### 5. **Performance**
Can optimize queries at the PublicApi level (e.g., `pluck_by_account_id`) without changing the Account model.

### 6. **Clear Boundaries**
It's obvious what's in the main app vs. what's in the engine.

## Common Patterns

### Pattern 1: Get Collection of DTOs
```ruby
users = account.users  # Returns array of DTOs
```

### Pattern 2: Get Count (Efficient)
```ruby
count = account.users_count  # Single SQL query, no DTOs
```

### Pattern 3: Get Raw Values (Efficient)
```ruby
ids = UserManagement::PublicApi::User.pluck_by_account_id(account.id, :id)
```

### Pattern 4: Complex Filtering
```ruby
# Get DTOs first, then filter in Ruby
admins = account.users.select(&:administrator?)

# OR query directly at PublicApi level (more efficient)
admins = UserManagement::PublicApi::User.administrators
  .select { |user| user.account_id == account.id }
```

## Conclusion

The `Account` model demonstrates proper use of the PublicApi pattern:
- No direct associations to engine models
- All engine data accessed through PublicApi
- Returns DTOs for safety and consistency
- Efficient queries when needed (pluck, count)
- Clean, maintainable architecture
