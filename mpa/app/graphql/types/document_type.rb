module Types
  class DocumentType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :content, String, null: true
    field :user_id, ID, null: false
    field :status, String, null: false
    field :storage_bytes, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
