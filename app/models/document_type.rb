class DocumentType < ApplicationRecord
  attr_accessor :is_canned

  has_many :documents
  has_many :document_types_groupings
  has_many :document_groups, through: :document_types
  has_many :employee_documents, through: :documents
  belongs_to :account, optional: true

  enum applies_to: { employees: 'employees', offices: 'offices' }

  validates :name, presence: true
  validates :name, uniqueness: { scope: :account_id,
                                 case_sensitive: false,
                                 allow_blank: true }

  default_scope { order(:name) }
  scope :canned, -> { where(account_id: nil) }
  scope :for_offices, -> { offices }
  scope :for_employees, -> { employees }

  delegate :name, to: :account, prefix: true, allow_nil: true

  def canned?
    account.nil?
  end
  alias_method :is_canned?, :canned?
end
