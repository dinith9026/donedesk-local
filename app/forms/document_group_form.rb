class DocumentGroupForm < ApplicationForm
  attribute :account_id, String
  attribute :name, String
  attribute :applies_to, String, default: 'employees'
  attribute :document_types_groupings, Array[DocumentTypesGroupingForm]

  validates :name, :document_types_groupings, presence: true
  validate :uniqueness_of_name

  def document_types
    context.document_types
  end

  def edit_path
    document_group_path(id: id)
  end

  private

  def uniqueness_of_name
    if groups_with_name.where.not(id: id).any?
      errors.add(:name, 'already taken')
    end
  end

  def groups_with_name
    DocumentGroup
      .where('lower(name) = ?', name.to_s.downcase)
      .where(account_id: account_id)
  end
end
