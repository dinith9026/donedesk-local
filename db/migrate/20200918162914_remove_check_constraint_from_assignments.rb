class RemoveCheckConstraintFromAssignments < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE assignments DROP CONSTRAINT IF EXISTS exactly_one_fk"
  end

  def down
    execute "ALTER TABLE assignments ADD CONSTRAINT exactly_one_fk CHECK (((course_id IS NOT NULL)::integer + (track_id IS NOT NULL)::integer) = 1)"
  end
end
