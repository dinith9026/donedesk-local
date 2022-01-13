class CreateContact < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts, id: :uuid do |t|
      t.timestamps

      t.string :contact_name, null: false
      t.string :contact_email, null: false
      t.string :contact_address, null: false
      t.string :contact_number_1, null: false
      t.string :contact_number_2, null: true
      t.references :account, type: :uuid, foreign_key: true
    end
  end
end
