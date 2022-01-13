class CreateIndexOnCoursesStates < ActiveRecord::Migration[5.0]
  def change
    add_index  :courses, :states, using: 'gin'
  end
end
