module UserManagement
  module Services
    class GraphqlClient
      class << self
        # Execute a GraphQL query against the main application
        def execute(query, variables: {})
          result = CohSchema.execute(
            query,
            variables: variables,
            context: {}
          )

          if result["errors"]
            Rails.logger.error("GraphQL Error: #{result['errors']}")
            return nil
          end

          result["data"]
        end

        # Get account for a user
        def get_account(account_id)
          return nil unless account_id

          query = <<~GRAPHQL
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
          GRAPHQL

          result = execute(query, variables: { id: account_id.to_s })
          result&.dig("accountForUser")
        end

        # Get documents for a user
        def get_documents(user_id, status: nil)
          return [] unless user_id

          query = <<~GRAPHQL
            query GetDocuments($userId: ID!, $status: String) {
              documentsForUser(userId: $userId, status: $status) {
                id
                title
                content
                userId
                status
                storageBytes
                createdAt
                updatedAt
              }
            }
          GRAPHQL

          variables = { userId: user_id.to_s }
          variables[:status] = status if status.present?

          result = execute(query, variables: variables)
          result&.dig("documentsForUser") || []
        end

        # Get document count for a user
        def get_documents_count(user_id)
          documents = get_documents(user_id)
          documents.size
        end

        # CREATE document
        def create_document(title:, user_id:, content: nil, status: nil)
          mutation = <<~GRAPHQL
            mutation CreateDocument($title: String!, $userId: ID!, $content: String, $status: String) {
              createDocument(input: { title: $title, userId: $userId, content: $content, status: $status }) {
                document {
                  id
                  title
                  content
                  userId
                  status
                  storageBytes
                  createdAt
                  updatedAt
                }
                errors
              }
            }
          GRAPHQL

          variables = { title: title, userId: user_id.to_s, content: content }
          variables[:status] = status if status.present?

          result = execute(mutation, variables: variables)
          result&.dig("createDocument", "document")
        end

        # UPDATE document
        def update_document(id:, **attributes)
          mutation = <<~GRAPHQL
            mutation UpdateDocument($id: ID!, $title: String, $content: String, $status: String) {
              updateDocument(input: { id: $id, title: $title, content: $content, status: $status }) {
                document {
                  id
                  title
                  content
                  userId
                  status
                  storageBytes
                  createdAt
                  updatedAt
                }
                errors
              }
            }
          GRAPHQL

          variables = { id: id.to_s }.merge(attributes)
          result = execute(mutation, variables: variables)
          result&.dig("updateDocument", "document")
        end

        # DELETE document
        def delete_document(id:)
          mutation = <<~GRAPHQL
            mutation DeleteDocument($id: ID!) {
              deleteDocument(input: { id: $id }) {
                success
                errors
              }
            }
          GRAPHQL

          result = execute(mutation, variables: { id: id.to_s })
          result&.dig("deleteDocument", "success")
        end
      end
    end
  end
end
