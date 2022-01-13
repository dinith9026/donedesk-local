class Office < ApplicationRecord
  belongs_to :account
  belongs_to :document_group
  has_many :document_types_groupings, through: :document_group
  has_many :office_documents
  has_many :documents, through: :office_documents
  has_many :employee_records
  has_many :offices_users
  has_many :employee_users, through: :employee_records, source: :user
  has_many :admins, through: :offices_users, source: :user
  has_many :contacts

  include CommonOfficeValidations

  delegate :time_tracking, :active_users, to: :account, prefix: true
  delegate :name, to: :document_group, prefix: true

  scope :tracks_time, ->  { where(tracks_time: true) }

  # TODO - preload this in the controller
  def is_admin?(user)
    offices_users.find { |office_user| office_user.user_id == user.id }
  end

  def active_admins
    admins.select { |admin| admin.employee_record_employed? }
  end

  def employed_employees
    employee_records.includes(:office).active
  end

  def active_assignments
    Assignment.active.for_employed_employees(employed_employees.pluck(:id))
  end

  def documents_for(document_type_id)
    office_documents.select do |office_document|
      office_document.document_type_id == document_type_id
    end.sort_by(&:created_at).reverse
  end

  def build_document(document)
    OfficeDocument.new(office: self, document: document)
  end
end
