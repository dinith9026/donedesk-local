class CreateJoinTableOfficesUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :offices_users, id: :uuid do |t|
      t.timestamps

      t.references :office, type: :uuid, foreign_key: { on_delete: :cascade }, null: false, index: true
      t.references :user, type: :uuid, foreign_key: { on_delete: :cascade }, null: false, index: true

      t.index [:office_id, :user_id], unique: true
    end
  end
end
