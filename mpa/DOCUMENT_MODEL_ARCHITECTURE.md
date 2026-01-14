# Document Model Architecture

## Overview

The `Document` model demonstrates proper integration with the `user_management` engine by **avoiding direct associations** to engine models and using the PublicApi/DTO pattern instead.

## Architecture Principles

### ❌ What We DON'T Do

```ruby
# BAD: Direct ActiveRecord association to engine model
class Document < ApplicationRecord
  belongs_to :user, class_name: "UserManagement::User", foreign_key: "user_id"
  delegate :account, to: :user
end
```

**Problems:**
- Direct coupling to internal engine model
- Breaks encapsulation
- Can't leverage DTO benefits
- Engine changes can break the main app

### ✅ What We DO

```ruby
# GOOD: Use PublicApi to access user data
class Document < ApplicationRecord
  validates :user_id, presence: true
  
  # Access user through PublicApi (returns DTO)
  def user
    return @user if defined?(@user)
    @user = UserManagement::PublicApi::User.find(user_id)
  end
  
  # Access account through user DTO
  def account
    user&.account_id ? Account.find_by(id: user.account_id) : nil
  end
end
```

**Benefits:**
- No direct coupling to engine models
- Returns DTOs (secure, controlled data)
- Memoization for performance (@user caching)
- Engine internals can change freely
- Clear separation of concerns

## Implementation Details

### 1. Foreign Key Without Association

The `documents` table has a `user_id` column, but we **don't use `belongs_to`**:

```ruby
class Document < ApplicationRecord
  # Note: user_id foreign key exists, but we access User through PublicApi
  # No direct association to UserManagement::User (engine model)
  
  validates :user_id, presence: true
end
```

**Why?**
- We need the foreign key for database integrity
- But we don't need ActiveRecord associations
- We access the user through PublicApi instead

### 2. User Method (Returns DTO)

```ruby
def user
  return @user if defined?(@user)
  @user = UserManagement::PublicApi::User.find(user_id)
end
```

**Features:**
- Returns `UserManagement::Dto::User` (not raw model)
- Memoized with `@user` for performance
- Returns `nil` if user not found (graceful)

**Usage:**
```ruby
document = Document.first
user = document.user  # => UserManagement::Dto::User

puts user.email
puts user.full_name
puts "Admin" if user.administrator?
```

### 3. Account Method (Through User DTO)

```ruby
def account
  user&.account_id ? Account.find_by(id: user.account_id) : nil
end
```

**Features:**
- Accesses account through user DTO
- Uses safe navigation (`&`) to handle nil user
- Returns Account model (not from engine)

**Usage:**
```ruby
document = Document.first
account = document.account  # => Account or nil

puts account.name if account
```

## Memoization Pattern

The `user` method uses memoization for performance:

```ruby
def user
  return @user if defined?(@user)  # Check if already loaded
  @user = UserManagement::PublicApi::User.find(user_id)  # Load if needed
end
```

**Why `defined?(@user)` instead of `@user ||=`?**
- `@user ||=` won't work if user is `nil`
- `defined?(@user)` checks if variable exists, not its value
- This correctly caches `nil` values too

## Usage Examples

### Example 1: Creating a Document

```ruby
# Get user from PublicApi
user = UserManagement::PublicApi::User.find(1)

# Create document with user_id
document = Document.create!(
  title: "My Document",
  content: "Document content",
  user_id: user.id
)

puts "Created: #{document.title}"
puts "Author: #{document.user.full_name}"
```

### Example 2: Accessing User Data

```ruby
document = Document.first

# Get user (returns DTO)
user = document.user
puts user.email
puts user.full_name
puts "Admin: #{user.administrator?}"

# Get account (through user)
account = document.account
puts "Account: #{account.name}" if account
```

### Example 3: Querying Documents

```ruby
# Find all documents for a specific user
user_id = 5
documents = Document.where(user_id: user_id)

documents.each do |doc|
  puts "#{doc.title} by #{doc.user.full_name}"
end
```

### Example 4: Account's Documents

```ruby
class Account < ApplicationRecord
  def documents
    user_ids = UserManagement::PublicApi::User.pluck_by_account_id(id, :id)
    Document.where(user_id: user_ids)
  end
end

account = Account.first
account.documents.each do |doc|
  puts "#{doc.title} by #{doc.user.full_name}"
end
```

## Performance Considerations

### 1. Memoization
The `user` method caches the result to avoid repeated API calls:

```ruby
document = Document.first

# First call: Fetches from PublicApi
user1 = document.user  # API call

# Second call: Returns cached value
user2 = document.user  # No API call, returns @user
```

### 2. N+1 Query Prevention

**Problem:**
```ruby
# ❌ N+1 queries
documents.each do |doc|
  puts doc.user.email  # One query per document!
end
```

**Solution:**
```ruby
# ✅ Preload users
user_ids = documents.pluck(:user_id)
users_by_id = UserManagement::PublicApi::User.where(id: user_ids)
  .index_by(&:id)

documents.each do |doc|
  user = users_by_id[doc.user_id]
  puts user.email
end
```

### 3. Efficient Queries

Use `pluck` when you only need IDs:

```ruby
# ✅ Efficient
user_ids = UserManagement::PublicApi::User.pluck_by_account_id(account_id, :id)
documents = Document.where(user_id: user_ids)

# ❌ Inefficient
users = UserManagement::PublicApi::User.where(account_id: account_id)
user_ids = users.map(&:id)  # Creates DTOs unnecessarily
documents = Document.where(user_id: user_ids)
```

## Validation

The Document model validates `user_id` presence:

```ruby
validates :user_id, presence: true
```

This ensures:
- Every document has a user
- Database integrity is maintained
- No orphaned documents

## Testing

All functionality has been tested:

✅ Document creation with user_id  
✅ `document.user` returns DTO  
✅ `document.account` works through user  
✅ Storage calculation still works  
✅ No direct association to engine model  
✅ Memoization prevents duplicate queries  

## Comparison: Before vs After

### Before (Direct Association)

```ruby
class Document < ApplicationRecord
  belongs_to :user, class_name: "UserManagement::User"
  delegate :account, to: :user
end

# Usage
document.user  # => UserManagement::User (raw model)
document.account  # => Account
```

**Issues:**
- Direct coupling to engine
- Exposes internal model
- Can't use DTO benefits

### After (PublicApi Pattern)

```ruby
class Document < ApplicationRecord
  validates :user_id, presence: true
  
  def user
    return @user if defined?(@user)
    @user = UserManagement::PublicApi::User.find(user_id)
  end
  
  def account
    user&.account_id ? Account.find_by(id: user.account_id) : nil
  end
end

# Usage
document.user  # => UserManagement::Dto::User (DTO)
document.account  # => Account
```

**Benefits:**
- No coupling to engine
- Returns secure DTOs
- Memoized for performance
- Future-proof

## Best Practices

### 1. Always Validate user_id
```ruby
validates :user_id, presence: true
```

### 2. Use Memoization
```ruby
def user
  return @user if defined?(@user)
  @user = UserManagement::PublicApi::User.find(user_id)
end
```

### 3. Handle nil Gracefully
```ruby
def account
  user&.account_id ? Account.find_by(id: user.account_id) : nil
end
```

### 4. Avoid N+1 Queries
```ruby
# Preload users when iterating
user_ids = documents.pluck(:user_id)
users = UserManagement::PublicApi::User.where(id: user_ids)
```

### 5. Use DTOs, Not Raw Models
```ruby
# ✅ Good
user_dto = document.user
puts user_dto.full_name

# ❌ Bad (don't access engine models directly)
user_model = UserManagement::User.find(document.user_id)
```

## Migration Guide

### If You Had Direct Associations

**Before:**
```ruby
class Document < ApplicationRecord
  belongs_to :user, class_name: "UserManagement::User"
end

document.user  # Returns UserManagement::User model
```

**After:**
```ruby
class Document < ApplicationRecord
  def user
    @user ||= UserManagement::PublicApi::User.find(user_id)
  end
end

document.user  # Returns UserManagement::Dto::User DTO
```

### Update Your Code

```ruby
# Before
document.user.email  # Works the same!

# After  
document.user.email  # Still works, but returns from DTO

# Before
if document.user.admin?
  # ...
end

# After
if document.user.administrator?  # Note: method name from DTO
  # ...
end
```

## Conclusion

The Document model demonstrates proper integration with the `user_management` engine:

- ✅ No direct `belongs_to` association
- ✅ Uses PublicApi for user access
- ✅ Returns DTOs (secure)
- ✅ Memoized for performance
- ✅ Maintains database integrity with `user_id` validation
- ✅ Clear separation between main app and engine

This pattern ensures the main application remains decoupled from engine internals while maintaining full functionality.
