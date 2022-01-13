class AddTrackIdToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_reference :assignments, :track, type: :uuid, foreign_key: { on_delete: :cascade}, index: true
  end
end
