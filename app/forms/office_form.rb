class OfficeForm < ApplicationForm
  attribute :account_id, String
  attribute :document_group_id, String
  attribute :name, String
  attribute :street_address, String
  attribute :address2, String
  attribute :city, String
  attribute :state, String
  attribute :zip, String
  attribute :phone, String
  attribute :time_zone, String
  attribute :tracks_time, Boolean, default: false

  include CommonOfficeValidations

  def document_groups
    context.current_account.document_groups.for_offices
  end
end
