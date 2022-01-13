class CreateEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :employees, id: :uuid do |t|
      t.references :office, foreign_key: true, type: :uuid
      t.string :title
      t.date :dob
      t.string :position
      t.string :phone_number
      t.string :emergency_contact_name
      t.string :emergency_contact_relationship
      t.string :emergency_contact_phone
      t.string :emergency_contact_email
      t.integer :employment_type
      t.integer :status
      t.integer :ssn
      t.integer :gender
      t.integer :marital_status

      t.timestamps
    end
  end
end
