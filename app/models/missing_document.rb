class MissingDocument < ApplicationRecord
  belongs_to :employee_record
  belongs_to :document_type

  scope :for_account, -> (account) { where(employee_record_id: account.employee_records.ids) }
end
