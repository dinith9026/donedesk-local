class Certificate < ApplicationRecord
  belongs_to :employee_record
  belongs_to :course

  delegate :title, :certificate_type, to: :course, prefix: true
  delegate :account_name, :full_name, :agd_member_number, to: :employee_record
end
