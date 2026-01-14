# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # Query account by ID
    field :account, Types::AccountType, null: true do
      argument :id, ID, required: true
    end

    def account(id:)
      Account.find_by(id: id)
    end

    # Query account by user's account_id
    field :account_for_user, Types::AccountType, null: true do
      argument :account_id, ID, required: true
    end

    def account_for_user(account_id:)
      Account.find_by(id: account_id)
    end

    # Query documents by user_id
    field :documents_for_user, [ Types::DocumentType ], null: false do
      argument :user_id, ID, required: true
      argument :status, String, required: false
    end

    def documents_for_user(user_id:, status: nil)
      docs = Document.where(user_id: user_id)
      docs = docs.where(status: status) if status.present?
      docs
    end

    # Query single document by ID
    field :document, Types::DocumentType, null: true do
      argument :id, ID, required: true
    end

    def document(id:)
      Document.find_by(id: id)
    end
  end
end
