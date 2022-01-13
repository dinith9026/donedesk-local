class AddCertificateTypeToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :certificate_type, :integer, null: false, default: 1
  end
end
