class AddMaterialUrlToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :material_url, :string
  end
end
