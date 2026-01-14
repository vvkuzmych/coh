# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_document, mutation: Mutations::CreateDocument
    field :update_document, mutation: Mutations::UpdateDocument
    field :delete_document, mutation: Mutations::DeleteDocument
  end
end
