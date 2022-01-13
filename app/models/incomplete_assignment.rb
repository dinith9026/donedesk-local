class IncompleteAssignment < ApplicationRecord
  belongs_to :assignment
  has_one :employee_record, through: :assignment
  has_one :course, through: :assignment

  scope :for_account, -> (account) { where(assignment_id: account.assignments.ids) }
end
