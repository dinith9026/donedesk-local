class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users, id: :uuid do |t|
      t.timestamps

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: true
    end
  end
end
