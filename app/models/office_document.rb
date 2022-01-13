class OfficeDocument < ApplicationRecord
  belongs_to :office
  belongs_to :document
  has_one :document_type, through: :document

  delegate :document_type, :document_type_id, :expiration, :expirable?, :expired?, :expires_on,
    :file_name, :is_confidential, :summary, :status, to: :document
  delegate :account_id, to: :office
  delegate :name, :is_admin?, to: :office, prefix: true

  validates :office_id, :document_id, presence: true

  scope :search, -> (q) {
    joins(:document_type).joins(:office).where(
      "offices.name ILIKE ? OR document_types.name ILIKE ?",
      "%#{q}%",
      "%#{q}%"
    )
  }
end
