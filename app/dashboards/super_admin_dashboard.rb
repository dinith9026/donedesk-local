class SuperAdminDashboard
  attr_reader :estimated_monthly_revenue, :total_documents, :total_active_accounts

  def initialize
    @estimated_monthly_revenue = EstimatedMonthlyRevenue.new.query
    @total_documents = Document.count
    @total_active_accounts = Account.active.count
  end
end
