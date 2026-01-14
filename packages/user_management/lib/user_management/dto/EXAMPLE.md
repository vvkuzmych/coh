# Creating New DTOs - Complete Example

This guide shows you how to create new DTOs using the `Dto::Base` class.

## Example: Creating an Account DTO

Let's say you want to create a DTO for the `Account` model.

### Step 1: Create the DTO File

**File**: `lib/user_management/dto/account.rb`

```ruby
module UserManagement
  module Dto
    class Account < Base
      # Define attributes from the Account model
      attributes :id, :name, :created_at, :updated_at

      # Add custom methods
      def created_at_formatted
        created_at.strftime("%B %d, %Y")
      end
    end
  end
end
```

### Step 2: Require the File

Add to `lib/user_management.rb`:

```ruby
require "user_management/dto/base"
require "user_management/dto/user"
require "user_management/dto/account"  # Add this line
```

### Step 3: Use It

```ruby
# From an Account model
account = Account.find(1)
dto = UserManagement::Dto::Account.new(account)

puts dto.id    # => 1
puts dto.name  # => "Acme Corp"
puts dto.created_at_formatted  # => "January 14, 2026"

# Convert to hash
dto.to_h
# => { id: 1, name: "Acme Corp", created_at: ..., updated_at: ... }
```

---

## Example: User Summary DTO (Subset of Attributes)

Sometimes you want a lighter DTO with only a subset of attributes.

**File**: `lib/user_management/dto/user_summary.rb`

```ruby
module UserManagement
  module Dto
    class UserSummary < Base
      # Only expose essential attributes
      attributes :id, :email, :first_name, :last_name

      def full_name
        "#{first_name} #{last_name}"
      end

      def initials
        "#{first_name[0]}#{last_name[0]}".upcase
      end
    end
  end
end
```

**Usage**:

```ruby
user = UserManagement::User.find(1)
summary = UserManagement::Dto::UserSummary.new(user)

puts summary.full_name  # => "John Doe"
puts summary.initials   # => "JD"

# Notice: summary.role would raise NoMethodError (not defined)
```

---

## Example: DTO with Nested Data

**File**: `lib/user_management/dto/user_with_account.rb`

```ruby
module UserManagement
  module Dto
    class UserWithAccount < Base
      attributes :id, :email, :first_name, :last_name, :role

      def initialize(user)
        super(user)

        # Add nested account DTO if account exists
        if user.account
          @account = Account.new(user.account)
        end
      end

      attr_reader :account

      def full_name
        "#{first_name} #{last_name}"
      end

      # Override to_h to include nested account
      def to_h
        super.merge(account: account&.to_h)
      end
    end
  end
end
```

**Usage**:

```ruby
user = UserManagement::User.includes(:account).find(1)
dto = UserManagement::Dto::UserWithAccount.new(user)

puts dto.email           # => "john@example.com"
puts dto.account.name    # => "Acme Corp"

dto.to_h
# => {
#   id: 1,
#   email: "john@example.com",
#   first_name: "John",
#   last_name: "Doe",
#   role: "admin",
#   account: {
#     id: 1,
#     name: "Acme Corp",
#     created_at: ...,
#     updated_at: ...
#   }
# }
```

---

## Example: DTO with Computed Attributes

**File**: `lib/user_management/dto/user_with_stats.rb`

```ruby
module UserManagement
  module Dto
    class UserWithStats < Base
      attributes :id, :email, :first_name, :last_name

      def initialize(user)
        super(user)

        # Compute statistics
        @document_count = user.documents.count
        @total_storage = user.documents.sum(:storage_bytes)
        @last_login = user.last_login_at
      end

      attr_reader :document_count, :total_storage, :last_login

      def full_name
        "#{first_name} #{last_name}"
      end

      def storage_mb
        (total_storage / 1024.0 / 1024.0).round(2)
      end

      # Override attribute_names to include computed attributes
      def self.attribute_names
        super + [:document_count, :total_storage, :last_login]
      end

      # Override to_h to include computed attributes
      def to_h
        super.merge(
          document_count: document_count,
          total_storage: total_storage,
          storage_mb: storage_mb,
          last_login: last_login
        )
      end
    end
  end
end
```

**Usage**:

```ruby
user = UserManagement::User.includes(:documents).find(1)
dto = UserManagement::Dto::UserWithStats.new(user)

puts dto.document_count  # => 42
puts dto.storage_mb      # => 15.32
puts dto.full_name       # => "John Doe"
```

---

## Example: DTO from Hash (for Testing)

```ruby
# Create a DTO without touching the database
dto = UserManagement::Dto::User.new({
  id: 999,
  email: "test@example.com",
  first_name: "Test",
  last_name: "User",
  account_id: 1,
  role: "guest",
  created_at: Time.current,
  updated_at: Time.current
})

# Use in tests
expect(dto.full_name).to eq("Test User")
expect(dto.regular_user?).to be true
```

---

## Example: DTO with Validation

**File**: `lib/user_management/dto/user_input.rb`

```ruby
module UserManagement
  module Dto
    class UserInput < Base
      attributes :email, :first_name, :last_name, :role

      def valid?
        errors.empty?
      end

      def errors
        errs = []
        errs << "Email must be present" if email.blank?
        errs << "Email must be valid" unless email&.include?("@")
        errs << "First name is required" if first_name.blank?
        errs << "Last name is required" if last_name.blank?
        errs << "Role must be valid" unless valid_role?
        errs
      end

      private

      def valid_role?
        %w[guest member admin super_admin].include?(role.to_s)
      end
    end
  end
end
```

**Usage**:

```ruby
# Invalid input
dto = UserManagement::Dto::UserInput.new({
  email: "invalid",
  first_name: "",
  last_name: "Doe",
  role: "hacker"
})

puts dto.valid?  # => false
puts dto.errors
# => [
#   "Email must be valid",
#   "First name is required",
#   "Role must be valid"
# ]

# Valid input
dto = UserManagement::Dto::UserInput.new({
  email: "john@example.com",
  first_name: "John",
  last_name: "Doe",
  role: "admin"
})

puts dto.valid?  # => true
```

---

## Example: Using DTOs in PublicApi

**File**: `lib/user_management/public_api/account.rb`

```ruby
module UserManagement
  module PublicApi
    class Account
      class << self
        def find(id)
          account = ::Account.find_by(id: id)
          return nil unless account

          UserManagement::Dto::Account.new(account)
        end

        def all
          accounts = ::Account.all
          accounts.map { |account| UserManagement::Dto::Account.new(account) }
        end

        def with_user_count
          accounts = ::Account.includes(:users).all
          accounts.map do |account|
            dto = UserManagement::Dto::Account.new(account)
            # Could create a specialized DTO here
            dto
          end
        end
      end
    end
  end
end
```

---

## Quick Reference: Creating a New DTO

### 1. Create the file

```bash
touch lib/user_management/dto/my_model.rb
```

### 2. Define the class

```ruby
module UserManagement
  module Dto
    class MyModel < Base
      # List the attributes you want to expose
      attributes :id, :name, :created_at

      # Add custom methods
      def formatted_name
        name.titleize
      end
    end
  end
end
```

### 3. Require it

Add to `lib/user_management.rb`:

```ruby
require "user_management/dto/my_model"
```

### 4. Use it

```ruby
model = MyModel.find(1)
dto = UserManagement::Dto::MyModel.new(model)

puts dto.name
puts dto.formatted_name
```

---

## Checklist for New DTOs

- [ ] Create file in `lib/user_management/dto/`
- [ ] Inherit from `Base`
- [ ] Define `attributes` with needed fields
- [ ] Add custom methods if needed
- [ ] Require in `lib/user_management.rb`
- [ ] Test with both ActiveRecord and hash initialization
- [ ] Document any special behavior

---

## Summary

The `Dto::Base` class makes creating new DTOs **incredibly simple**:

1. **3 lines minimum** (class definition + attributes + end)
2. **No boilerplate** (no attr_reader, no initialize)
3. **Automatic methods** (to_h, to_json, inspect)
4. **Consistent behavior** across all DTOs

Happy DTO-ing! 🚀
