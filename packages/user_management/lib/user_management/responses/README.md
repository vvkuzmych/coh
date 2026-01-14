# GraphQL Response Classes

## Overview

Instead of using `OpenStruct`, we use **dedicated Response classes** for GraphQL data. These are simple, lightweight value objects that provide:

- ✅ **Explicit attributes** - Clear, documented fields
- ✅ **Type safety** - No dynamic attribute creation
- ✅ **Serialization** - `to_h` method for easy conversion
- ✅ **Better performance** - No metaprogramming overhead
- ✅ **IDE support** - Autocomplete and type hints work

## Why Not OpenStruct?

### ❌ Problems with OpenStruct

```ruby
# OpenStruct allows any attribute (dangerous!)
obj = OpenStruct.new(name: "John")
obj.name     # => "John"
obj.age      # => nil (no error, returns nil)
obj.anything # => nil (no error, returns nil)

# Typos go unnoticed
obj.naem     # => nil (should be 'name', but no error!)
```

### ✅ Benefits of Response Classes

```ruby
# Response class has explicit attributes
response = AccountResponse.new(data)
response.name           # => "John"
response.users_count    # => 5
response.age            # NoMethodError (good - catches typos!)
response.naem           # NoMethodError (catches typos!)
```

## Response Classes

### AccountResponse

**File:** `lib/user_management/responses/account_response.rb`

```ruby
module UserManagement
  module Responses
    class AccountResponse
      attr_reader :id, :name, :users_count, :documents_count, 
                  :total_storage_bytes, :created_at, :updated_at

      def initialize(data)
        @id = data["id"]
        @name = data["name"]
        @users_count = data["usersCount"]
        @documents_count = data["documentsCount"]
        @total_storage_bytes = data["totalStorageBytes"]
        @created_at = data["createdAt"]
        @updated_at = data["updatedAt"]
      end

      def to_h
        {
          id: id,
          name: name,
          users_count: users_count,
          documents_count: documents_count,
          total_storage_bytes: total_storage_bytes,
          created_at: created_at,
          updated_at: updated_at
        }
      end
    end
  end
end
```

**Usage:**
```ruby
data = GraphqlClient.get_account(account_id)
account = AccountResponse.new(data)

puts account.name           # => "My Account"
puts account.users_count    # => 5
```

### DocumentResponse

**File:** `lib/user_management/responses/document_response.rb`

```ruby
module UserManagement
  module Responses
    class DocumentResponse
      attr_reader :id, :title, :content, :user_id, 
                  :storage_bytes, :created_at, :updated_at

      def initialize(data)
        @id = data["id"]
        @title = data["title"]
        @content = data["content"]
        @user_id = data["userId"]
        @storage_bytes = data["storageBytes"]
        @created_at = data["createdAt"]
        @updated_at = data["updatedAt"]
      end

      def to_h
        {
          id: id,
          title: title,
          content: content,
          user_id: user_id,
          storage_bytes: storage_bytes,
          created_at: created_at,
          updated_at: updated_at
        }
      end
    end
  end
end
```

**Usage:**
```ruby
data = GraphqlClient.get_documents(user_id)
documents = data.map { |doc| DocumentResponse.new(doc) }

documents.each do |doc|
  puts doc.title
  puts doc.storage_bytes
end
```

## Usage in User Model

```ruby
class UserManagement::User < ApplicationRecord
  def account
    return @account if defined?(@account)
    @account = account_id ? fetch_account : nil
  end

  def documents
    return @documents if defined?(@documents)
    @documents = fetch_documents
  end

  private

  def fetch_account
    data = UserManagement::Services::GraphqlClient.get_account(account_id)
    return nil unless data

    UserManagement::Responses::AccountResponse.new(data)
  end

  def fetch_documents
    data = UserManagement::Services::GraphqlClient.get_documents(id)
    data.map { |doc| UserManagement::Responses::DocumentResponse.new(doc) }
  end
end
```

## Benefits

### 1. Explicit Attributes

```ruby
# You know exactly what attributes are available
response = AccountResponse.new(data)
response.name           # Defined ✅
response.users_count    # Defined ✅
response.invalid_field  # NoMethodError ✅ (catches bugs!)
```

### 2. Documentation

```ruby
# IDE autocomplete works
account.u # Shows: users_count, updated_at

# Easy to see what fields exist
AccountResponse.new(data).public_methods
```

### 3. Type Safety

```ruby
# Can add validation/type coercion
def initialize(data)
  @id = data["id"].to_i
  @name = data["name"].to_s
  @users_count = data["usersCount"].to_i
end
```

### 4. Serialization

```ruby
account = AccountResponse.new(data)
account.to_h  # Easy conversion to hash
account.to_h.to_json  # Easy JSON serialization
```

### 5. Better Performance

```ruby
# OpenStruct uses method_missing (slow)
obj = OpenStruct.new(name: "John")
obj.name  # Calls method_missing internally

# Response class uses attr_reader (fast)
response = AccountResponse.new(name: "John")
response.name  # Direct method call
```

## Adding New Response Classes

### Template

```ruby
module UserManagement
  module Responses
    class MyResponse
      attr_reader :field1, :field2, :field3

      def initialize(data)
        @field1 = data["field1"]
        @field2 = data["field2"]
        @field3 = data["field3"]
      end

      def to_h
        {
          field1: field1,
          field2: field2,
          field3: field3
        }
      end
    end
  end
end
```

### Steps

1. Create file in `lib/user_management/responses/`
2. Define `attr_reader` for all fields
3. Parse GraphQL data in `initialize`
4. Implement `to_h` for serialization
5. Require in `lib/user_management/engine.rb`

## Comparison

| Feature | OpenStruct | Response Class |
|---------|-----------|----------------|
| Performance | Slow (method_missing) | Fast (direct methods) |
| Type Safety | ❌ No | ✅ Yes |
| IDE Support | ❌ No autocomplete | ✅ Full autocomplete |
| Catches Typos | ❌ No | ✅ Yes (NoMethodError) |
| Explicit API | ❌ No | ✅ Yes |
| Serialization | ❌ No to_h | ✅ Has to_h |
| Validation | ❌ No | ✅ Can add |
| Memory | Higher | Lower |

## Best Practices

### 1. Always Define to_h

```ruby
def to_h
  {
    id: id,
    name: name,
    # ... all fields
  }
end
```

### 2. Handle nil Gracefully

```ruby
def initialize(data)
  @id = data["id"]
  @name = data["name"] || "Unknown"  # Default value
  @count = data["count"].to_i        # Safe conversion
end
```

### 3. Add Helper Methods

```ruby
class AccountResponse
  attr_reader :id, :name, :users_count

  def initialize(data)
    @id = data["id"]
    @name = data["name"]
    @users_count = data["usersCount"]
  end

  def has_users?
    users_count > 0
  end

  def display_name
    "#{name} (#{users_count} users)"
  end
end
```

### 4. Keep Classes Simple

- No business logic
- Just data mapping
- Pure value objects

## Testing

```ruby
# Example test
data = {
  "id" => "1",
  "name" => "Test Account",
  "usersCount" => 5
}

response = AccountResponse.new(data)

assert_equal "1", response.id
assert_equal "Test Account", response.name
assert_equal 5, response.users_count
```

## Conclusion

Response classes provide:
- ✅ Better performance than OpenStruct
- ✅ Type safety and error catching
- ✅ IDE support and documentation
- ✅ Explicit, maintainable code
- ✅ Easy serialization

Use them for all GraphQL response data!
