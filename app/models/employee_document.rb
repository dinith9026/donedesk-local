class EmployeeDocument < ApplicationRecord
  belongs_to :employee_record
  belongs_to :document
  has_one :document_type, through: :document

  delegate :summary, :document_type, :document_type_id, :is_confidential, :file_name,
    :expiration, :expirable?, :expired?, :expires_on, :expires_in, :expiring_soon?, :status,
    to: :document
  delegate :name, to: :document, prefix: true
  delegate :full_name, :office, :first_initial_and_last, :office_name, to: :employee_record, prefix: true
  delegate :account_id, to: :employee_record

  validates :employee_record_id, :document_id, presence: true

  scope :search, -> (q) {
    joins(:document_type).joins(:employee_record).where(
      "employee_records.first_name ILIKE ? OR employee_records.last_name ILIKE ? OR document_types.name ILIKE ?",
      "%#{q}%",
      "%#{q}%",
      "%#{q}%"
    )
  }
end
