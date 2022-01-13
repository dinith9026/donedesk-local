class RemovePaperclipMaterialFieldsFromCourses < ActiveRecord::Migration[5.0]
  def up
    remove_column :courses, :material_file_name
    remove_column :courses, :material_content_type
    remove_column :courses, :material_file_size
    remove_column :courses, :material_updated_at
  end
end
