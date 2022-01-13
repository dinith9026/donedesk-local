class PlanForm < ApplicationForm
  attribute :monthly_price, Integer
  attribute :max_employees, Integer

  validates :monthly_price, :max_employees,
              presence: true
  validates :monthly_price,
              numericality: true
  validates :max_employees,
              numericality: { greater_than: 0, allow_blank: true }
end
