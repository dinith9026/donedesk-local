class AddAttachmentMaterialToCourses < ActiveRecord::Migration[5.0]
  def self.up
    change_table :courses do |t|
      t.attachment :material
    end
  end

  def self.down
    remove_attachment :courses, :material
  end
end
