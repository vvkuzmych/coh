# PublicApi CRUD Operations

The `UserManagement::PublicApi::Base` class provides complete CRUD (Create, Read, Update, Delete) operations that work seamlessly with the DTO pattern.

## Overview

All operations that return data **return DTOs**, ensuring data encapsulation and security. The PublicApi acts as the gateway between the main application and the engine's internal models.

## CREATE Operations

### `create(**attributes)`
Create a new record. Returns DTO or `nil` if validation fails.

```ruby
user = UserManagement::PublicApi::User.create(
  email: "user@example.com",
  first_name: "John",
  last_name: "Doe",
  role: 0
)

if user
  puts user.full_name  # => "John Doe"
  puts user.class      # => UserManagement::Dto::User
else
  puts "Validation failed"
end
```

### `create!(**attributes)`
Create a new record. Raises exception if validation fails.

```ruby
begin
  user = UserManagement::PublicApi::User.create!(
    email: "user@example.com",
    first_name: "John",
    last_name: "Doe"
  )
  puts "Created: #{user.email}"
rescue ActiveRecord::RecordInvalid => e
  puts "Validation error: #{e.message}"
end
```

### `batch_create(attributes_array)`
Create multiple records at once. Returns array of DTOs.

```ruby
users = UserManagement::PublicApi::User.batch_create([
  { email: "user1@example.com", first_name: "John", last_name: "Doe", role: 0 },
  { email: "user2@example.com", first_name: "Jane", last_name: "Smith", role: 1 }
])

puts "Created #{users.count} users"
users.each { |user| puts user.full_name }
```

### `upsert(find_attributes, **update_attributes)`
Create if doesn't exist, update if exists. Returns DTO.

```ruby
# First call creates
user = UserManagement::PublicApi::User.upsert(
  { email: "user@example.com" },
  first_name: "John",
  last_name: "Doe"
)

# Second call updates the same record
user = UserManagement::PublicApi::User.upsert(
  { email: "user@example.com" },
  first_name: "Updated John"
)
```

## READ Operations

### `find(id)`
Find a single record by ID. Returns DTO or `nil`.

```ruby
user = UserManagement::PublicApi::User.find(1)
puts user.email if user
```

### `find_by(**attributes)`
Find a single record by attributes. Returns DTO or `nil`.

```ruby
user = UserManagement::PublicApi::User.find_by(email: "user@example.com")
puts user.full_name if user
```

### `all`
Get all records. Returns array of DTOs.

```ruby
users = UserManagement::PublicApi::User.all
users.each { |user| puts user.email }
```

### `where(**conditions)`
Get records matching conditions. Returns array of DTOs.

```ruby
admins = UserManagement::PublicApi::User.where(role: 2)
admins.each { |admin| puts admin.full_name }
```

### `first(limit = 1)`
Get first N records. Returns DTO or array of DTOs.

```ruby
first_user = UserManagement::PublicApi::User.first
# or
first_five = UserManagement::PublicApi::User.first(5)
```

### `last(limit = 1)`
Get last N records. Returns DTO or array of DTOs.

```ruby
last_user = UserManagement::PublicApi::User.last
# or
last_five = UserManagement::PublicApi::User.last(5)
```

### `count`
Count all records. Returns integer.

```ruby
total = UserManagement::PublicApi::User.count
puts "Total users: #{total}"
```

### `count_where(**conditions)`
Count records matching conditions. Returns integer.

```ruby
admin_count = UserManagement::PublicApi::User.count_where(role: 2)
puts "Total admins: #{admin_count}"
```

### `exists?(**conditions)`
Check if any records exist. Returns boolean.

```ruby
if UserManagement::PublicApi::User.exists?(email: "user@example.com")
  puts "User exists"
end
```

### `pluck(*attributes)`
Get raw values without creating DTOs. Returns array.

```ruby
emails = UserManagement::PublicApi::User.pluck(:email)
# => ["user1@example.com", "user2@example.com"]

id_and_email = UserManagement::PublicApi::User.pluck(:id, :email)
# => [[1, "user1@example.com"], [2, "user2@example.com"]]
```

### `query(&block)`
Execute custom query. Returns array of DTOs.

```ruby
users = UserManagement::PublicApi::User.query do |model|
  model.where(role: 2).order(created_at: :desc).limit(10)
end
```

## UPDATE Operations

### `update(id, **attributes)`
Update a record by ID. Returns DTO or `nil` if not found/failed.

```ruby
user = UserManagement::PublicApi::User.update(1, first_name: "Updated")
if user
  puts "Updated: #{user.full_name}"
else
  puts "Not found or validation failed"
end
```

### `update!(id, **attributes)`
Update a record by ID. Raises exception if not found or validation fails.

```ruby
begin
  user = UserManagement::PublicApi::User.update!(1, first_name: "Updated")
  puts "Updated: #{user.full_name}"
rescue ActiveRecord::RecordNotFound
  puts "User not found"
rescue ActiveRecord::RecordInvalid => e
  puts "Validation error: #{e.message}"
end
```

### `update_by(conditions, **attributes)`
Update multiple records matching conditions. Returns count of updated records.

```ruby
updated = UserManagement::PublicApi::User.update_by(
  { role: 0 },
  role: 1
)
puts "Updated #{updated} users"
```

## DELETE Operations

### `delete(id)`
Delete a record by ID. Returns `true` if deleted, `false` if not found.

```ruby
if UserManagement::PublicApi::User.delete(1)
  puts "User deleted"
else
  puts "User not found"
end
```

### `delete!(id)`
Delete a record by ID. Raises exception if not found.

```ruby
begin
  UserManagement::PublicApi::User.delete!(1)
  puts "User deleted"
rescue ActiveRecord::RecordNotFound
  puts "User not found"
end
```

### `delete_by(**conditions)`
Delete multiple records matching conditions. Returns count of deleted records.

```ruby
deleted = UserManagement::PublicApi::User.delete_by(role: 0)
puts "Deleted #{deleted} guest users"
```

### `delete_all`
Delete all records. **Use with extreme caution!** Returns count of deleted records.

```ruby
deleted = UserManagement::PublicApi::User.delete_all
puts "Deleted #{deleted} users"
```

## Complete CRUD Example

```ruby
# CREATE
user = UserManagement::PublicApi::User.create(
  email: "john@example.com",
  first_name: "John",
  last_name: "Doe",
  role: 0
)
puts "Created: #{user.id} - #{user.full_name}"

# READ
user = UserManagement::PublicApi::User.find(user.id)
puts "Found: #{user.email}"

# UPDATE
user = UserManagement::PublicApi::User.update(user.id, first_name: "Updated John")
puts "Updated: #{user.full_name}"

# DELETE
if UserManagement::PublicApi::User.delete(user.id)
  puts "Deleted successfully"
end
```

## Usage in Account Model

```ruby
class Account < ApplicationRecord
  def users
    UserManagement::PublicApi::User.where(account_id: id)
  end
  
  def create_user(email:, first_name:, last_name:)
    UserManagement::PublicApi::User.create(
      email: email,
      first_name: first_name,
      last_name: last_name,
      account_id: id,
      role: 0
    )
  end
  
  def update_user(user_id, **attributes)
    UserManagement::PublicApi::User.update(user_id, **attributes)
  end
  
  def delete_user(user_id)
    UserManagement::PublicApi::User.delete(user_id)
  end
end
```

## Return Values Summary

| Operation | Success Return | Failure Return |
|-----------|---------------|----------------|
| `create` | DTO | `nil` |
| `create!` | DTO | Raises exception |
| `batch_create` | Array of DTOs | Array (may include nils) |
| `upsert` | DTO | Always returns DTO |
| `find` | DTO | `nil` |
| `find_by` | DTO | `nil` |
| `all` | Array of DTOs | Empty array |
| `where` | Array of DTOs | Empty array |
| `count` | Integer | Integer (0 if none) |
| `exists?` | Boolean | Boolean |
| `pluck` | Array of values | Empty array |
| `update` | DTO | `nil` |
| `update!` | DTO | Raises exception |
| `update_by` | Integer (count) | Integer (0 if none) |
| `delete` | `true` | `false` |
| `delete!` | `true` | Raises exception |
| `delete_by` | Integer (count) | Integer (0 if none) |
| `delete_all` | Integer (count) | Integer (0 if none) |

## Best Practices

### 1. Use Bang Methods When You Expect Success
```ruby
# Good - clear that failure is exceptional
user = UserManagement::PublicApi::User.create!(attrs)

# Avoid - silent failures are harder to debug
user = UserManagement::PublicApi::User.create(attrs)
```

### 2. Check Return Values for Non-Bang Methods
```ruby
user = UserManagement::PublicApi::User.update(id, attrs)
if user
  # Success
else
  # Handle not found or validation failure
end
```

### 3. Use Batch Operations When Appropriate
```ruby
# Good - single transaction
users = UserManagement::PublicApi::User.batch_create(array_of_attrs)

# Avoid - multiple transactions
array_of_attrs.each do |attrs|
  UserManagement::PublicApi::User.create(attrs)
end
```

### 4. Use Pluck for Performance
```ruby
# Good - no DTOs created, just raw values
ids = UserManagement::PublicApi::User.pluck(:id)

# Avoid - creates unnecessary DTOs
ids = UserManagement::PublicApi::User.all.map(&:id)
```

### 5. Use Upsert for Idempotent Operations
```ruby
# Good - always succeeds, creates or updates
user = UserManagement::PublicApi::User.upsert(
  { email: email },
  first_name: first_name
)

# Avoid - need to check if exists first
user = UserManagement::PublicApi::User.find_by(email: email)
if user
  UserManagement::PublicApi::User.update(user.id, first_name: first_name)
else
  UserManagement::PublicApi::User.create(email: email, first_name: first_name)
end
```

## Testing CRUD Operations

All CRUD operations have been tested and verified:

✅ CREATE - Creates model and returns DTO  
✅ READ - Finds model and returns DTO  
✅ UPDATE - Updates model and returns DTO  
✅ DELETE - Deletes model and returns boolean  
✅ BATCH_CREATE - Creates multiple models  
✅ UPSERT - Creates or updates seamlessly  
✅ UPDATE_BY - Updates by conditions  
✅ DELETE_BY - Deletes by conditions  

## Error Handling

### Validation Errors
```ruby
begin
  user = UserManagement::PublicApi::User.create!(invalid_attrs)
rescue ActiveRecord::RecordInvalid => e
  puts "Validation failed: #{e.record.errors.full_messages}"
end
```

### Not Found Errors
```ruby
begin
  user = UserManagement::PublicApi::User.update!(999, attrs)
rescue ActiveRecord::RecordNotFound
  puts "User with ID 999 not found"
end
```

### Graceful Degradation
```ruby
user = UserManagement::PublicApi::User.find(id)
if user
  # Work with user
else
  # Handle not found gracefully
  redirect_to users_path, alert: "User not found"
end
```
