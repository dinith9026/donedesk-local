class EmployeeNote < ApplicationRecord
  belongs_to :employee_record
  belongs_to :creator, class_name: 'User'

  include CommonEmployeeNoteValidations

  delegate :full_name, to: :creator, prefix: true
end
