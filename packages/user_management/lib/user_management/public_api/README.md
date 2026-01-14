# PublicApi Base Class Documentation

## Overview

The `UserManagement::PublicApi::Base` class provides a reusable foundation for creating Public API classes that automatically wrap ActiveRecord models into DTOs.

## Features

✅ **Automatic DTO wrapping** - All results automatically converted to DTOs  
✅ **Common query methods** - `find`, `all`, `where`, `count`, `exists?`, etc.  
✅ **Lazy model loading** - Models loaded on-demand (no eager loading issues)  
✅ **Zero boilerplate** - Just configure and extend  
✅ **Collection handling** - Automatic mapping of collections to DTOs  
✅ **Custom methods** - Easy to add domain-specific methods  

---

## Basic Usage

### Step 1: Define Your PublicApi

```ruby
module UserManagement
  module PublicApi
    class User < Base
      # Configure which model and DTO to use
      # Use string for model_class to avoid eager loading
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      # Add custom methods
      def self.get_all_by_account_id(account_id)
        where(account_id: account_id)
      end
    end
  end
end
```

### Step 2: Use the API

```ruby
# Find by ID - returns DTO or nil
dto = UserManagement::PublicApi::User.find(1)
puts dto.email  # => "user@example.com"

# Get all - returns array of DTOs
dtos = UserManagement::PublicApi::User.all

# Query - returns array of DTOs
admins = UserManagement::PublicApi::User.where(role: :admin)

# Custom method
account_users = UserManagement::PublicApi::User.get_all_by_account_id(1)
```

---

## How It Works

### 1. Configuration

The `configure` method tells the PublicApi which model and DTO to use:

```ruby
configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User
```

**Important**: Use a **string** for `model_class` to avoid eager loading issues. The class will be loaded lazily when first accessed.

### 2. Automatic DTO Wrapping

All query methods automatically wrap results in DTOs:

```ruby
# Behind the scenes:
def self.find(id)
  model = model_class.find_by(id: id)  # Gets UserManagement::User
  wrap(model)                           # Returns UserManagement::Dto::User
end
```

### 3. The `wrap` Methods

Two core methods handle DTO conversion:

- `wrap(model)` - Wraps a single model to DTO
- `wrap_collection(models)` - Wraps an array of models to DTOs

---

## Built-in Methods

### Query Methods

#### `find(id)`
Find a single record by ID.

```ruby
dto = UserManagement::PublicApi::User.find(1)
# => UserManagement::Dto::User or nil
```

#### `find_by(**attributes)`
Find a single record by attributes.

```ruby
dto = UserManagement::PublicApi::User.find_by(email: "user@example.com")
# => UserManagement::Dto::User or nil
```

#### `all`
Get all records.

```ruby
dtos = UserManagement::PublicApi::User.all
# => Array of UserManagement::Dto::User
```

#### `where(**conditions)`
Get records matching conditions.

```ruby
dtos = UserManagement::PublicApi::User.where(role: :admin)
# => Array of UserManagement::Dto::User

dtos = UserManagement::PublicApi::User.where(account_id: 1, role: :admin)
# => Array of UserManagement::Dto::User
```

#### `first(limit = 1)`
Get first N records.

```ruby
dto = UserManagement::PublicApi::User.first
# => UserManagement::Dto::User

dtos = UserManagement::PublicApi::User.first(10)
# => Array of UserManagement::Dto::User (up to 10)
```

#### `last(limit = 1)`
Get last N records.

```ruby
dto = UserManagement::PublicApi::User.last
# => UserManagement::Dto::User

dtos = UserManagement::PublicApi::User.last(10)
# => Array of UserManagement::Dto::User (up to 10)
```

---

### Count Methods

#### `count`
Count all records.

```ruby
total = UserManagement::PublicApi::User.count
# => 42
```

#### `count_where(**conditions)`
Count records matching conditions.

```ruby
admin_count = UserManagement::PublicApi::User.count_where(role: :admin)
# => 5
```

#### `exists?(**conditions)`
Check if any records exist.

```ruby
exists = UserManagement::PublicApi::User.exists?(email: "user@example.com")
# => true or false
```

---

### Utility Methods

#### `pluck(*attributes)`
Get raw values (not DTOs).

```ruby
emails = UserManagement::PublicApi::User.pluck(:email)
# => ["user1@example.com", "user2@example.com", ...]

ids_and_emails = UserManagement::PublicApi::User.pluck(:id, :email)
# => [[1, "user1@example.com"], [2, "user2@example.com"], ...]
```

#### `query(&block)`
Execute a custom query and wrap results.

```ruby
dtos = UserManagement::PublicApi::User.query do |model_class|
  model_class.where(active: true).order(:name).limit(10)
end
# => Array of UserManagement::Dto::User
```

---

## Custom Methods

### Pattern 1: Using Built-in Methods

```ruby
module UserManagement
  module PublicApi
    class User < Base
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      # Use `where` from base
      def self.get_all_by_account_id(account_id)
        where(account_id: account_id)
      end

      # Use `find_by` from base
      def self.find_by_email(email)
        find_by(email: email)
      end
    end
  end
end
```

### Pattern 2: Using Scopes

```ruby
module UserManagement
  module PublicApi
    class User < Base
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      # Access model scopes and wrap results
      def self.administrators
        users = model_class.administrators
        wrap_collection(users)
      end

      def self.regular_users
        users = model_class.regular_users
        wrap_collection(users)
      end
    end
  end
end
```

### Pattern 3: Using Query Block

```ruby
module UserManagement
  module PublicApi
    class User < Base
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      def self.active_in_account(account_id)
        query do |model_class|
          model_class
            .where(account_id: account_id, active: true)
            .order(:last_name, :first_name)
        end
      end
    end
  end
end
```

### Pattern 4: Complex Queries

```ruby
module UserManagement
  module PublicApi
    class User < Base
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      def self.search(term)
        query do |model_class|
          model_class
            .where("email LIKE ? OR first_name LIKE ? OR last_name LIKE ?",
                   "%#{term}%", "%#{term}%", "%#{term}%")
            .limit(50)
        end
      end

      def self.recently_active(days: 7)
        query do |model_class|
          model_class
            .where("last_login_at > ?", days.days.ago)
            .order(last_login_at: :desc)
        end
      end
    end
  end
end
```

---

## Examples

### Example 1: Simple PublicApi

```ruby
module UserManagement
  module PublicApi
    class User < Base
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      # That's it! You get all built-in methods:
      # - find(id)
      # - find_by(...)
      # - all
      # - where(...)
      # - count
      # - exists?(...)
      # etc.
    end
  end
end
```

Usage:
```ruby
# All these work out of the box
UserManagement::PublicApi::User.find(1)
UserManagement::PublicApi::User.all
UserManagement::PublicApi::User.where(role: :admin)
UserManagement::PublicApi::User.count
```

### Example 2: PublicApi with Custom Methods

```ruby
module UserManagement
  module PublicApi
    class User < Base
      configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User

      # Custom methods using built-in methods
      def self.by_account(account_id)
        where(account_id: account_id)
      end

      def self.by_email(email)
        find_by(email: email)
      end

      # Custom methods using scopes
      def self.administrators
        wrap_collection(model_class.administrators)
      end

      # Custom methods with complex logic
      def self.active_users_in_account(account_id, role: nil)
        query do |model_class|
          scope = model_class.where(account_id: account_id, active: true)
          scope = scope.where(role: role) if role
          scope.order(:email)
        end
      end
    end
  end
end
```

### Example 3: Account PublicApi

```ruby
module UserManagement
  module PublicApi
    class Account < Base
      configure model_class: "::Account", dto_class: UserManagement::Dto::Account

      def self.with_users
        query do |model_class|
          model_class.includes(:users)
        end
      end

      def self.search_by_name(name)
        where("name LIKE ?", "%#{name}%")
      end
    end
  end
end
```

---

## Testing

### Testing PublicApi Methods

```ruby
RSpec.describe UserManagement::PublicApi::User do
  describe ".find" do
    it "returns a DTO" do
      user = create(:user)
      dto = described_class.find(user.id)

      expect(dto).to be_a(UserManagement::Dto::User)
      expect(dto.id).to eq(user.id)
    end

    it "returns nil for non-existent user" do
      dto = described_class.find(999999)
      expect(dto).to be_nil
    end
  end

  describe ".all" do
    it "returns array of DTOs" do
      create_list(:user, 3)
      dtos = described_class.all

      expect(dtos).to all(be_a(UserManagement::Dto::User))
      expect(dtos.count).to eq(3)
    end
  end

  describe ".where" do
    it "filters by attributes" do
      admin = create(:user, role: :admin)
      member = create(:user, role: :member)

      dtos = described_class.where(role: :admin)

      expect(dtos.count).to eq(1)
      expect(dtos.first.id).to eq(admin.id)
    end
  end

  describe ".administrators" do
    it "returns only admin users" do
      admin = create(:user, role: :admin)
      super_admin = create(:user, role: :super_admin)
      member = create(:user, role: :member)

      dtos = described_class.administrators

      expect(dtos.count).to eq(2)
      expect(dtos.map(&:id)).to contain_exactly(admin.id, super_admin.id)
    end
  end
end
```

---

## Benefits

### 1. **Less Boilerplate**

**Without Base:**
```ruby
class User
  def self.find(id)
    user = UserManagement::User.find_by(id: id)
    return nil unless user
    UserManagement::Dto::User.new(user)
  end

  def self.all
    users = UserManagement::User.all
    users.map { |user| UserManagement::Dto::User.new(user) }
  end

  # ... many more methods
end
```

**With Base:**
```ruby
class User < Base
  configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User
  # All methods inherited!
end
```

### 2. **Consistency**

All PublicApi classes behave the same way:
- Same query methods
- Same DTO wrapping
- Same error handling

### 3. **Safety**

- Always returns DTOs (never exposes models directly)
- Handles nil cases automatically
- Lazy loading prevents eager loading issues

### 4. **Extensibility**

Easy to add custom methods:
- Use inherited methods internally
- Access model_class for custom queries
- Use wrap/wrap_collection for manual wrapping

---

## Best Practices

### ✅ DO

- Use string for `model_class` to avoid eager loading
- Use `where` for simple queries
- Use `query` block for complex queries
- Use `wrap_collection` when working with scopes
- Add custom methods for domain-specific needs

### ❌ DON'T

- Don't expose ActiveRecord models directly
- Don't bypass DTO wrapping
- Don't perform database writes in PublicApi (that's for a Service layer)
- Don't use eager `UserManagement::User` in configure

---

## Summary

The `PublicApi::Base` class provides:

- ✅ **Zero boilerplate** for common queries
- ✅ **Automatic DTO wrapping** for all results
- ✅ **Consistent interface** across all APIs
- ✅ **Easy customization** with custom methods
- ✅ **Lazy loading** to avoid eager loading issues

**Perfect for building clean API boundaries in your modular monolith!**
