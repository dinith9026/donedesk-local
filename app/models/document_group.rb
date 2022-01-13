class DocumentGroup < ApplicationRecord
  belongs_to :account
  has_many :employee_records
  has_many :offices
  has_many :document_types_groupings
  has_many :document_types, through: :document_types_groupings

  enum applies_to: { employees: 'employees', offices: 'offices' }

  validates :name, :document_types_groupings, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id,
                                                 case_sensitive: false,
                                                 allow_blank: true }

  scope :for_offices, -> { offices }
  scope :for_employees, -> { employees }
end
