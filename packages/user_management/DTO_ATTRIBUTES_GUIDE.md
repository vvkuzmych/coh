# DTO Attributes Guide

## Overview

The DTO Base class now supports **two types of attributes**:

1. **Base Attributes** (`attributes`) - Extracted from the source object
2. **Computed Attributes** (`dto_attributes`) - Custom methods that are included in serialization

---

## Usage

### Step 1: Define Base Attributes

These are extracted directly from the source object (ActiveRecord model or hash):

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  # Attributes from the User model
  attributes :id, :email, :first_name, :last_name, :account_id, :role, :created_at, :updated_at
end
```

### Step 2: Define Computed Attributes

These are custom methods that should be included in `to_h`, `to_json`, and `inspect`:

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  attributes :id, :email, :first_name, :last_name, :account_id, :role, :created_at, :updated_at
  
  # Register computed attributes
  dto_attributes :full_name, :administrator?, :regular_user?
  
  # Define the methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def administrator?
    role == "admin" || role == "super_admin"
  end
  
  def regular_user?
    role == "guest" || role == "member"
  end
end
```

---

## Benefits of `dto_attributes`

### ✅ **Automatic Serialization**

Computed attributes are automatically included in `to_h` and `to_json`:

```ruby
dto = UserManagement::Dto::User.new(user)

dto.to_h
# => {
#   id: 1,
#   email: "john@example.com",
#   first_name: "John",
#   last_name: "Doe",
#   role: "admin",
#   full_name: "John Doe",              # ← Computed attribute
#   administrator?: true,                # ← Computed attribute
#   regular_user?: false                 # ← Computed attribute
# }
```

### ✅ **Better Inspection**

Computed attributes appear in `inspect`:

```ruby
dto.inspect
# => #<UserManagement::Dto::User id=1, email="john@example.com", first_name="John", last_name="Doe", role="admin", full_name="John Doe", administrator?=true, regular_user?=false>
```

### ✅ **Clear Separation**

You can query which attributes are base vs computed:

```ruby
UserManagement::Dto::User.base_attribute_names
# => [:id, :email, :first_name, :last_name, :account_id, :role, :created_at, :updated_at]

UserManagement::Dto::User.computed_attribute_names
# => [:full_name, :administrator?, :regular_user?]

UserManagement::Dto::User.attribute_names
# => [:id, :email, :first_name, :last_name, :account_id, :role, :created_at, :updated_at, :full_name, :administrator?, :regular_user?]
```

---

## Examples

### Example 1: Simple Computed Attribute

```ruby
class UserManagement::Dto::User < Base
  attributes :first_name, :last_name
  dto_attributes :full_name
  
  def full_name
    "#{first_name} #{last_name}"
  end
end

dto = UserManagement::Dto::User.new(user)
dto.to_h
# => { first_name: "John", last_name: "Doe", full_name: "John Doe" }
```

### Example 2: Boolean Computed Attributes

```ruby
class UserManagement::Dto::User < Base
  attributes :role, :active
  dto_attributes :administrator?, :can_edit?
  
  def administrator?
    role == "admin" || role == "super_admin"
  end
  
  def can_edit?
    active && administrator?
  end
end

dto = UserManagement::Dto::User.new(user)
dto.to_h
# => { role: "admin", active: true, administrator?: true, can_edit?: true }
```

### Example 3: Formatted Attributes

```ruby
class UserManagement::Dto::User < Base
  attributes :created_at, :email
  dto_attributes :created_at_formatted, :email_domain
  
  def created_at_formatted
    created_at.strftime("%B %d, %Y")
  end
  
  def email_domain
    email.split("@").last
  end
end

dto = UserManagement::Dto::User.new(user)
dto.to_h
# => {
#   created_at: 2026-01-14 07:00:00 UTC,
#   email: "john@example.com",
#   created_at_formatted: "January 14, 2026",
#   email_domain: "example.com"
# }
```

### Example 4: Statistics Computed Attributes

```ruby
class UserManagement::Dto::UserWithStats < Base
  attributes :id, :email
  dto_attributes :document_count, :storage_mb, :last_active
  
  def initialize(user)
    super(user)
    @user = user  # Store for computed attributes
  end
  
  def document_count
    @user.documents.count
  end
  
  def storage_mb
    (@user.documents.sum(:storage_bytes) / 1024.0 / 1024.0).round(2)
  end
  
  def last_active
    @user.last_login_at&.strftime("%Y-%m-%d %H:%M")
  end
end
```

---

## Comparison: Before vs After

### Before (without `dto_attributes`)

```ruby
class User < Base
  attributes :id, :email, :first_name, :last_name
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Problem: full_name NOT included in to_h
  def to_h
    super.merge(full_name: full_name)  # Manual override needed
  end
end

dto.to_h
# => { id: 1, email: "...", first_name: "...", last_name: "...", full_name: "..." }
```

### After (with `dto_attributes`)

```ruby
class User < Base
  attributes :id, :email, :first_name, :last_name
  dto_attributes :full_name  # ← Declare it here
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # No need to override to_h!
end

dto.to_h
# => { id: 1, email: "...", first_name: "...", last_name: "...", full_name: "..." }
```

---

## When to Use `dto_attributes`

### ✅ Use `dto_attributes` for:

- **Computed values** that should be in serialization
- **Formatted attributes** (dates, numbers, etc.)
- **Boolean helpers** (`administrator?`, `active?`)
- **Derived data** (`full_name`, `age`, `status`)
- **Statistics** (`document_count`, `storage_mb`)

### ❌ Don't use `dto_attributes` for:

- **Internal helper methods** not meant for serialization
- **Methods with side effects** (database queries, API calls)
- **Methods that take arguments** (only zero-argument methods work)

---

## Best Practices

### 1. Keep Computed Attributes Simple

```ruby
# ✅ Good - simple computation
def full_name
  "#{first_name} #{last_name}"
end

# ❌ Bad - complex logic, database query
def recent_documents
  @user.documents.where("created_at > ?", 7.days.ago)
end
```

### 2. Declare All Computed Attributes

```ruby
# ✅ Good - all methods declared
dto_attributes :full_name, :administrator?, :initials

# ❌ Bad - some methods not declared
dto_attributes :full_name
# administrator? method exists but not declared - won't be in to_h
```

### 3. Use Descriptive Names

```ruby
# ✅ Good - clear names
dto_attributes :full_name, :created_at_formatted, :storage_mb

# ❌ Bad - unclear names
dto_attributes :name, :date, :size
```

---

## Testing

### Test Attribute Lists

```ruby
RSpec.describe UserManagement::Dto::User do
  describe "attribute configuration" do
    it "has correct base attributes" do
      expect(described_class.base_attribute_names).to contain_exactly(
        :id, :email, :first_name, :last_name, :account_id, :role, :created_at, :updated_at
      )
    end
    
    it "has correct computed attributes" do
      expect(described_class.computed_attribute_names).to contain_exactly(
        :full_name, :administrator?, :regular_user?
      )
    end
    
    it "combines all attributes" do
      expect(described_class.attribute_names).to eq(
        described_class.base_attribute_names + described_class.computed_attribute_names
      )
    end
  end
end
```

### Test Serialization

```ruby
RSpec.describe UserManagement::Dto::User do
  describe "#to_h" do
    it "includes computed attributes" do
      user = create(:user, first_name: "John", last_name: "Doe", role: :admin)
      dto = described_class.new(user)
      hash = dto.to_h
      
      expect(hash[:full_name]).to eq("John Doe")
      expect(hash[:administrator?]).to be true
      expect(hash[:regular_user?]).to be false
    end
  end
end
```

---

## Summary

The `dto_attributes` method provides:

✅ **Automatic serialization** of computed attributes  
✅ **Clear declaration** of what's included in to_h  
✅ **Better inspect output**  
✅ **Separation** between base and computed attributes  
✅ **Zero boilerplate** for serialization  

**Usage**:
```ruby
class MyDto < Base
  attributes :id, :name           # From source object
  dto_attributes :formatted_name  # Computed method
  
  def formatted_name
    name.titleize
  end
end
```

**Result**: All attributes (base + computed) automatically included in `to_h`, `to_json`, and `inspect`! 🎉
