class CreateOffices < ActiveRecord::Migration[5.0]
  def change
    create_table :offices, id: :uuid do |t|
      t.timestamps

      t.string :name, null: false
      t.string :street_address, null: false
      t.string :address2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.string :phone, null: false
      t.references :account, type: :uuid, foreign_key: true

      t.index [:name, :account_id], unique: true
    end
  end
end
