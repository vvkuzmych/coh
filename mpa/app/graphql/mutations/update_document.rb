module Mutations
  class UpdateDocument < BaseMutation
    description "Updates a document"

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :content, String, required: false
    argument :status, String, required: false

    field :document, Types::DocumentType, null: true
    field :errors, [ String ], null: false

    def resolve(id:, **attributes)
      document = Document.find_by(id: id)

      unless document
        return {
          document: nil,
          errors: [ "Document not found" ]
        }
      end

      if document.update(attributes.compact)
        {
          document: document,
          errors: []
        }
      else
        {
          document: nil,
          errors: document.errors.full_messages
        }
      end
    end
  end
end
