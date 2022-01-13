class AddPassingThresholdPercentageToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :passing_threshold_percentage, :integer, null: false
  end
end
