class CreateCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :certificates, id: :uuid do |t|
      t.timestamps

      t.date :passed_on, null: false
      t.date :expires_on
      t.references :employee_record, type: :uuid, index: true, foreign_key: true
      t.references :course, type: :uuid, index: true, foreign_key: true
    end
  end
end
