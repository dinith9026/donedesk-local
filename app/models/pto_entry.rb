class PTOEntry < ApplicationRecord
  belongs_to :employee_record

  delegate :account_id, to: :employee_record
  delegate :full_name, to: :employee_record, prefix: true

  include CommonPTOEntryValidations

  validates :employee_record, presence: true

  scope :within, -> (date_range) do
    where(date: date_range).eager_load(:employee_record).order(:date)
  end
end
