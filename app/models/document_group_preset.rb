class DocumentGroupPreset < ApplicationRecord
  enum applies_to: { employees: 'employees', offices: 'offices' }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :document_types, presence: true
  validate :document_types_applies_to_match_group_applies_to

  scope :for_offices, -> { where(applies_to: 'offices') }
  scope :for_employees, -> { where(applies_to: 'employees') }

  private

  def document_types_applies_to_match_group_applies_to
    ids = document_types.map { |values| values['id'] }

    DocumentType.where(id: ids).each do |document_type|
      if document_type.applies_to != applies_to
        errors.add(:base, "You can only select document types that apply to #{applies_to}")
      end
    end
  end
end
