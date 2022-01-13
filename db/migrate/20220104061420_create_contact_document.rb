class CreateContactDocument < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_documents do |t|
      t.string :file_name, null: true
      t.string :file_path, null: true
      t.references :contact, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
