# GraphQL Architecture: Engine to Monolith Communication

## Overview

The `user_management` engine communicates with the main monolith application through **GraphQL** instead of direct ActiveRecord associations. This provides:

- ✅ **Complete decoupling** - Engine knows nothing about monolith's internal models
- ✅ **Clean API boundary** - GraphQL schema acts as a contract
- ✅ **Versioning support** - Can evolve the schema without breaking changes
- ✅ **Type safety** - GraphQL enforces types and validation
- ✅ **Flexibility** - Can query exactly what's needed

## Architecture Principles

### ❌ What We DON'T Have

```ruby
# NO direct ActiveRecord associations
class User < ApplicationRecord
  belongs_to :account              # ❌ Removed
  has_many :documents              # ❌ Removed
end
```

### ✅ What We HAVE

```ruby
# User model uses GraphQL to fetch related data
class User < ApplicationRecord
  def account
    # Fetches via GraphQL query
    UserManagement::Services::GraphqlClient.get_account(account_id)
  end

  def documents
    # Fetches via GraphQL query
    UserManagement::Services::GraphqlClient.get_documents(id)
  end
end
```

## Components

### 1. Main Application (Monolith)

**GraphQL Schema** (`mpa/app/graphql/`)
- **Types**: `AccountType`, `DocumentType`
- **Queries**: `account`, `accountForUser`, `documentsForUser`, `document`
- **Mutations**: `createDocument`, `updateDocument`, `deleteDocument`

### 2. User Management Engine

**GraphQL Client Service** (`packages/user_management/lib/user_management/services/graphql_client.rb`)
- Executes GraphQL queries/mutations against main app
- Returns parsed data (Hashes/Arrays)

**User Model** (`packages/user_management/app/models/user_management/user.rb`)
- No ActiveRecord associations
- Methods that call GraphQL client
- Returns OpenStruct objects (lightweight data containers)

## GraphQL Schema

### Queries (READ)

#### Get Account
```graphql
query GetAccount($id: ID!) {
  accountForUser(accountId: $id) {
    id
    name
    usersCount
    documentsCount
    totalStorageBytes
    createdAt
    updatedAt
  }
}
```

#### Get Documents for User
```graphql
query GetDocuments($userId: ID!) {
  documentsForUser(userId: $userId) {
    id
    title
    content
    userId
    storageBytes
    createdAt
    updatedAt
  }
}
```

### Mutations (WRITE)

#### Create Document
```graphql
mutation CreateDocument($title: String!, $userId: ID!, $content: String) {
  createDocument(input: { title: $title, userId: $userId, content: $content }) {
    document {
      id
      title
      content
      userId
      storageBytes
    }
    errors
  }
}
```

#### Update Document
```graphql
mutation UpdateDocument($id: ID!, $title: String, $content: String) {
  updateDocument(input: { id: $id, title: $title, content: $content }) {
    document {
      id
      title
      content
    }
    errors
  }
}
```

#### Delete Document
```graphql
mutation DeleteDocument($id: ID!) {
  deleteDocument(input: { id: $id }) {
    success
    errors
  }
}
```

## GraphQL Client Service

### Usage

```ruby
# READ operations
account = UserManagement::Services::GraphqlClient.get_account(account_id)
documents = UserManagement::Services::GraphqlClient.get_documents(user_id)

# WRITE operations
doc = UserManagement::Services::GraphqlClient.create_document(
  title: "New Doc",
  user_id: user.id,
  content: "Content"
)

updated = UserManagement::Services::GraphqlClient.update_document(
  id: doc_id,
  title: "Updated Title"
)

deleted = UserManagement::Services::GraphqlClient.delete_document(id: doc_id)
```

### Implementation

```ruby
module UserManagement
  module Services
    class GraphqlClient
      class << self
        def execute(query, variables: {})
          result = CohSchema.execute(query, variables: variables, context: {})

          if result["errors"]
            Rails.logger.error("GraphQL Error: #{result['errors']}")
            return nil
          end

          result["data"]
        end

        def get_account(account_id)
          # ... GraphQL query ...
        end

        def get_documents(user_id)
          # ... GraphQL query ...
        end

        def create_document(title:, user_id:, content: nil)
          # ... GraphQL mutation ...
        end
      end
    end
  end
end
```

## User Model Implementation

### Before (With Associations)

```ruby
class User < ApplicationRecord
  belongs_to :account, optional: true
  has_many :documents, dependent: :destroy

  # Direct database access
end
```

### After (With GraphQL)

```ruby
class User < ApplicationRecord
  # No associations!

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

    OpenStruct.new(
      id: data["id"],
      name: data["name"],
      users_count: data["usersCount"],
      # ... other fields ...
    )
  end

  def fetch_documents
    data = UserManagement::Services::GraphqlClient.get_documents(id)
    data.map { |doc| OpenStruct.new(doc) }
  end
end
```

## Benefits

### 1. Complete Decoupling
Engine doesn't know about `Account` or `Document` models - only their GraphQL representations.

### 2. Memoization
Data is cached per request:
```ruby
user.account  # First call: GraphQL query
user.account  # Second call: Returns @account (cached)
```

### 3. Type Safety
GraphQL schema enforces types and validates queries.

### 4. Versioning
Can add new fields without breaking existing queries:
```graphql
type Account {
  id: ID!
  name: String!
  newField: String  # Add without breaking clients
}
```

### 5. Flexible Queries
Can request exactly what's needed:
```graphql
query {
  account(id: "1") {
    name          # Only fetch name
  }
}
```

### 6. Clear API Boundary
GraphQL schema serves as a contract between engine and monolith.

## Usage Examples

### Example 1: Accessing Related Data

```ruby
user = UserManagement::User.first

# Get account (via GraphQL)
account = user.account
puts account.name
puts account.users_count

# Get documents (via GraphQL)
documents = user.documents
documents.each do |doc|
  puts doc.title
  puts doc.storage_bytes
end
```

### Example 2: Creating Data

```ruby
user = UserManagement::User.first

# Create document via GraphQL mutation
doc_data = UserManagement::Services::GraphqlClient.create_document(
  title: "My Document",
  content: "Content here",
  user_id: user.id
)

puts "Created: #{doc_data['title']}"
```

### Example 3: In Controllers

```ruby
class UsersController < ApplicationController
  def show
    @user = UserManagement::PublicApi::User.find(params[:id])
    @account = @user.account        # Fetches via GraphQL
    @documents = @user.documents     # Fetches via GraphQL
  end
end
```

## Performance Considerations

### 1. Memoization
```ruby
def account
  return @account if defined?(@account)  # Cache per request
  @account = fetch_account
end
```

### 2. N+1 Queries Prevention
```ruby
# ❌ Bad: N+1 GraphQL queries
users.each do |user|
  puts user.account.name  # GraphQL query per user!
end

# ✅ Good: Batch fetch
account_ids = users.pluck(:account_id).compact.uniq
accounts = account_ids.map do |id|
  UserManagement::Services::GraphqlClient.get_account(id)
end
accounts_by_id = accounts.index_by { |a| a["id"] }

users.each do |user|
  account = accounts_by_id[user.account_id.to_s]
  puts account["name"]
end
```

### 3. Selective Field Fetching
Only request fields you need:
```graphql
query {
  documentsForUser(userId: "1") {
    id
    title
    # Don't fetch content if not needed
  }
}
```

## Testing

All CRUD operations tested and working:

✅ **Queries (READ)** - Fetch account and documents via GraphQL  
✅ **Mutations (CREATE)** - Create documents via GraphQL  
✅ **Mutations (UPDATE)** - Update documents via GraphQL  
✅ **Mutations (DELETE)** - Delete documents via GraphQL  
✅ **No ActiveRecord associations** - User model has 0 associations  

## GraphiQL Interface

GraphiQL is available for testing queries:

1. Start the Rails server
2. Visit: `http://localhost:3000/graphiql`
3. Try queries and mutations interactively

Example query:
```graphql
{
  account(id: "1") {
    name
    documentsCount
  }
}
```

## Migration Guide

### If You Had ActiveRecord Associations

**Before:**
```ruby
user.account              # Returns Account model
user.documents            # Returns ActiveRecord::Relation
user.documents.create!()  # Direct model creation
```

**After:**
```ruby
user.account              # Returns OpenStruct with account data
user.documents            # Returns Array of OpenStructs
# For writes, use GraphQL mutations:
UserManagement::Services::GraphqlClient.create_document(...)
```

## Best Practices

### 1. Memoize in Model Methods
```ruby
def account
  return @account if defined?(@account)
  @account = fetch_account
end
```

### 2. Handle nil Gracefully
```ruby
def fetch_account
  data = GraphqlClient.get_account(account_id)
  return nil unless data
  OpenStruct.new(data)
end
```

### 3. Log GraphQL Errors
```ruby
if result["errors"]
  Rails.logger.error("GraphQL Error: #{result['errors']}")
  return nil
end
```

### 4. Use OpenStruct for Return Values
```ruby
OpenStruct.new(
  id: data["id"],
  name: data["name"]
)
```

### 5. Keep GraphQL Client Simple
- One method per query/mutation
- Return parsed data (not raw GraphQL results)
- Handle errors at the client level

## Conclusion

The GraphQL-based architecture provides:
- ✅ Complete decoupling between engine and monolith
- ✅ Clear API contract (GraphQL schema)
- ✅ Type safety and validation
- ✅ Flexible, efficient queries
- ✅ Easy to version and evolve
- ✅ No ActiveRecord associations needed

This pattern is ideal for modular monoliths where you want strong boundaries between modules while maintaining a single codebase.
