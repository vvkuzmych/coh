module Types
  class AccountType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :users_count, Integer, null: false
    field :documents_count, Integer, null: false
    field :total_storage_bytes, Integer, null: false

    def users_count
      object.users_count
    end

    def documents_count
      object.documents_count
    end

    def total_storage_bytes
      object.total_storage_bytes
    end
  end
end
