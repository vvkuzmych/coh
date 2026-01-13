class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.bigint :storage_bytes, default: 0, null: false

      t.timestamps
    end

    add_index :documents, :title
    add_index :documents, [ :user_id, :created_at ]
  end
end
