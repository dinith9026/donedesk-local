class CreateContactNote < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_notes do |t|
      t.text :note, null: true
      t.references :contact, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
