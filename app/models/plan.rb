class Plan < ApplicationRecord
  belongs_to :account

  delegate :name, to: :account, prefix: true

  validates :monthly_price, :max_employees,
              numericality: { only_integer: true }

  def name
    "#{max_employees} Employees Plan"
  end

  # IMPORTANT
  # Changing this could break ref to existing Stripe Plan
  def stripe_plan_id
    "#{id}-#{interval}ly"
  end

  def interval
    'month'
  end

  def currency
    'usd'
  end

  def monthly_price_in_cents
    100 * monthly_price
  end

  def to_s
    "$#{monthly_price}/#{interval} for #{max_employees} employees"
  end
end
