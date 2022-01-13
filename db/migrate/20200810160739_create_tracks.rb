class CreateTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :tracks, id: :uuid do |t|
      t.timestamps

      t.references :account, foreign_key: true, type: :uuid, null: false
      t.string :name, null: false
    end

    add_index :tracks, [:name, :account_id], unique: true
  end
end
