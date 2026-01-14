module Mutations
  class DeleteDocument < BaseMutation
    description "Deletes a document"

    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [ String ], null: false

    def resolve(id:)
      document = Document.find_by(id: id)

      unless document
        return {
          success: false,
          errors: [ "Document not found" ]
        }
      end

      if document.destroy
        {
          success: true,
          errors: []
        }
      else
        {
          success: false,
          errors: document.errors.full_messages
        }
      end
    end
  end
end
