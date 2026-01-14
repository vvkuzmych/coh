# DTO Base Class

The `UserManagement::Dto::Base` class provides a foundation for creating Data Transfer Objects (DTOs) in the UserManagement engine.

## Purpose

DTOs serve as a safe, controlled way to expose data from internal models to external consumers. They:

1. **Encapsulate data** - Only expose what's needed
2. **Prevent coupling** - External code doesn't depend on internal model structure
3. **Enable versioning** - You can change internal models without breaking external APIs
4. **Improve security** - No accidental exposure of sensitive data

## Usage

### Basic Example

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  # Define attributes one at a time
  dto_attribute :id
  dto_attribute :email
  dto_attribute :first_name
  dto_attribute :last_name
end
```

### With Model Methods

The `dto_attribute` method reads both regular attributes AND model methods from the source object:

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  # Regular attributes
  dto_attribute :id
  dto_attribute :email
  dto_attribute :first_name
  dto_attribute :last_name
  
  # Model methods (computed attributes)
  dto_attribute :full_name
  dto_attribute :administrator?
  dto_attribute :regular_user?
end
```

**Important:** Custom methods like `full_name`, `administrator?`, and `regular_user?` should be defined in the **model**, not in the DTO. The DTO simply reads their values.

### With Transformations

You can optionally provide a block to transform the value:

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  dto_attribute :id
  
  # Transform email to lowercase
  dto_attribute :email do |value|
    value.downcase
  end
  
  # Transform date to formatted string
  dto_attribute :created_at do |value|
    value.strftime("%Y-%m-%d")
  end
  
  # Format full name with title
  dto_attribute :full_name do |value|
    "Mr./Ms. #{value}"
  end
end
```

## Creating a DTO

```ruby
user = UserManagement::User.first
dto = UserManagement::Dto::User.new(user)

# Access attributes
dto.id           # => 1
dto.email        # => "user@example.com" (or transformed value)
dto.full_name    # => "John Doe" (read from model method)
dto.administrator? # => true (read from model method)
```

## Converting to Hash/JSON

```ruby
dto.to_h
# => { id: 1, email: "user@example.com", first_name: "John", ..., full_name: "John Doe", administrator?: true }

dto.to_json
# => JSON string with all attributes
```

## How It Works

1. **Declaration**: Use `dto_attribute` to declare each attribute/method to read
2. **Optional Transformation**: Provide a block to transform the value
3. **Initialization**: When you create a DTO with `new(source_object)`, it:
   - Reads all declared attributes from the source
   - Applies transformations if defined
   - Stores values in instance variables
4. **Access**: Reader methods are automatically created for all attributes

## Features

- **Single attribute declaration** - Clear, explicit, one-per-line syntax
- **Optional transformations** - Transform values with blocks
- **Automatic reader methods** - No need to manually define `attr_reader`
- **Supports special characters** - Methods like `administrator?` work correctly
- **Hash support** - Can initialize from Hash or ActiveRecord model
- **Serialization** - Built-in `to_h` and `to_json` methods
- **Inspection** - Nice `inspect` output for debugging

## Examples

### Simple User DTO

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  dto_attribute :id
  dto_attribute :email
  dto_attribute :first_name
  dto_attribute :last_name
  dto_attribute :full_name
end
```

### User DTO with Transformations

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  dto_attribute :id
  
  dto_attribute :email do |value|
    value.downcase
  end
  
  dto_attribute :first_name
  dto_attribute :last_name
  
  dto_attribute :full_name do |value|
    value.titleize
  end
  
  dto_attribute :created_at do |value|
    value.to_date
  end
end
```

### Document DTO

```ruby
class UserManagement::Dto::Document < UserManagement::Dto::Base
  dto_attribute :id
  dto_attribute :title
  
  dto_attribute :content do |value|
    value.truncate(100)
  end
  
  dto_attribute :user_id
  dto_attribute :created_at
  
  dto_attribute :formatted_date
  dto_attribute :word_count
  dto_attribute :published?
end
```

## Best Practices

1. **Keep logic in models** - DTOs should only read and transform data, not compute it
2. **Be explicit** - One attribute per line for clarity
3. **Use transformations wisely** - Only for presentation/format changes, not business logic
4. **Document transformations** - Add comments explaining why transformations are needed
5. **Version carefully** - Changing DTO structure affects external consumers

## Advanced: Conditional Attributes

```ruby
class UserManagement::Dto::User < UserManagement::Dto::Base
  dto_attribute :id
  dto_attribute :email
  
  # Only include if present
  dto_attribute :phone do |value|
    value.presence
  end
  
  # Safe navigation
  dto_attribute :account_name do |value|
    value&.name || "No Account"
  end
end
```

## Technical Details

### Instance Variable Sanitization
Ruby doesn't allow special characters in instance variable names, so:
- `administrator?` → stored as `@administrator`
- `active!` → stored as `@active`

### Reader Method Creation
Reader methods are created using `define_method` to support special characters:
```ruby
define_method(attr) do
  instance_variable_get(ivar_name)
end
```

### Transformation Execution
Transformations are stored and executed during initialization:
```ruby
value = transformation.call(value) if transformation
```
