class EstimatedMonthlyRevenue < ApplicationQuery
  def query
    Account.active.registered.joins(:plan).sum('plans.monthly_price')
  end
end
