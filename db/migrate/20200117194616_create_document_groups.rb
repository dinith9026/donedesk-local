class CreateDocumentGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :document_groups, id: :uuid do |t|
      t.timestamps

      t.string :title, index: true
      t.references :account, type: :uuid, index: true, foreign_key: true
    end
  end
end
