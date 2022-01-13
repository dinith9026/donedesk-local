class AddMaterialS3KeyToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :material_s3_key, :string
    execute "UPDATE courses SET material_s3_key = concat_ws('/', 'courses/materials', id::text, material_file_name::text)"
  end
end
