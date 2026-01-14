module Mutations
  class CreateDocument < BaseMutation
    description "Creates a new document"

    argument :title, String, required: true
    argument :content, String, required: false
    argument :user_id, ID, required: true
    argument :status, String, required: false

    field :document, Types::DocumentType, null: true
    field :errors, [ String ], null: false

    def resolve(title:, user_id:, content: nil, status: nil)
      document = Document.new(
        title: title,
        content: content,
        user_id: user_id
      )
      document.status = status if status.present?

      if document.save
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
