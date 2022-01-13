class EmployeeRecordForm < ApplicationForm
  attribute :user_id, String
  attribute :office_id, String
  attribute :document_group_id, String
  attribute :first_name, String
  attribute :last_name, String
  attribute :title, String
  attribute :dob, Date
  attribute :phone, String
  attribute :address, String
  attribute :emergency_contact_name, String
  attribute :emergency_contact_relationship, String
  attribute :emergency_contact_phone, String
  attribute :emergency_contact_email, String
  attribute :marital_status, String
  attribute :employment_type, Integer
  attribute :hired_on, Date
  attribute :terminated_on, Date
  attribute :user, UserForm
  attribute :track_ids, Array
  attribute :agd_member_number, String

  validates :first_name, :last_name, :office_id, :employment_type, presence: true
  validates :document_group_id, presence: true, if: Proc.new { |f| f.editable?(:document_group_id) }

  def offices
    @offices = ListOfficesForAccount.new(context.current_account.id).query
  end

  def document_groups
    context.current_account.document_groups.for_employees
  end

  def dob_formatted
    if dob.present?
      I18n.l(dob.to_date, format: :default)
    else
      ''
    end
  end

  def hired_on_formatted
    if hired_on.present?
      I18n.l(hired_on.to_date, format: :default)
    else
      ''
    end
  end

  def terminated_on_formatted
    if terminated_on.present?
      I18n.l(terminated_on.to_date, format: :default)
    else
      ''
    end
  end
end
