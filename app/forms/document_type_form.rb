class DocumentTypeForm < ApplicationForm
  attribute :name, String
  attribute :applies_to, String
  attribute :account_id, String
  attribute :is_confidential, Boolean, default: false
  attribute :is_canned, Boolean, default: false

  validates :name, presence: true
  validate :name_is_unique_for_account

  def name_is_unique_for_account
    if document_types_with_name.where.not(id: id).any?
      errors.add(:name, 'already taken')
    end
  end

  private

  def document_types_with_name
    FindDocumentTypeForAccountWithName.new(name, account_id).query
  end
end
