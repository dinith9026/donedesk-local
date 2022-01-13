class AccountAdminsDashboard
  attr_reader :missing_documents, :expired_documents, :expiring_documents,
    :past_due_or_expired_assignments, :due_soon_or_expiring_soon_assignments

  delegate :plan_max_employees, to: :account

  def initialize(user)
    @user = user
    @policy = EmployeeRecordPolicy.new(@user, EmployeeRecord.new)
    @account = user.account
    @employee_records = account.employee_records
    @compliance_stats = account.account_compliance_stats
    @missing_documents = get_missing_documents(@account)
    @expired_documents = get_expired_documents(@account)
    @expiring_documents = get_expiring_documents(@account)
    @past_due_or_expired_assignments = get_past_due_or_expired_assignments(@account)
    @due_soon_or_expiring_soon_assignments = get_due_soon_or_expiring_soon_assignments(@account)
  end

  def when_show_compliance_stats_for_offices(&block)
    yield
  end

  def when_many_offices(&block)
    if @user.account_offices.count > 2
      yield
    end
  end

  def new_employee_record_form
    EmployeeRecordForm
      .new
      .with_policy(@policy)
      .with_context(current_account: @user.account, user: @user.account_manager? ? @user : nil)
  end

  def offices
    OfficesPresenter.new(@account.offices, @user)
  end

  def disable_calc_stats_btn?
    account.is_calculating_compliance_stats
  end

  def stats_last_updated_at
    account.compliance_stats_last_updated_at.strftime('%a, %b %e, %Y %I:%M %p')
  end

  def document_compliance_percentage
    compliance_stats&.document_compliance_percentage || 0
  end

  def training_compliance_percentage
    compliance_stats&.training_compliance_percentage || 0
  end

  def active_employee_records
    EmployeeRecordsPresenter.new(@account.active_employee_records, @user)
  end

  def when_calculating_stats(&block)
    if account.is_calculating_compliance_stats
      yield
    end
  end

  def when_not_calculating_stats(&block)
    unless account.is_calculating_compliance_stats
      yield
    end
  end

  def when_employee_records_exist(&block)
    if @employee_records.any?
      yield if block_given?
    end
  end

  def when_no_employee_records_exist(&block)
    unless @employee_records.any?
      yield if block_given?
    end
  end

  def expiring_soon_threshold
    Document::EXPIRING_SOON_THRESHOLD
  end

  def past_due_or_expired_assignments_count
    @past_due_or_expired_assignments.length
  end

  def due_soon_or_expiring_soon_assignments_count
    @due_soon_or_expiring_soon_assignments.length
  end

  private

  attr_reader :account, :compliance_stats

  def get_missing_documents(account)
    MissingDocument
      .for_account(account)
      .joins(:employee_record)
      .joins(:document_type)
      .select("employee_records.id AS employee_record_id, CONCAT(employee_records.last_name, ', ', employee_records.first_name) AS employee_name, document_types.name AS document_name")
      .order('employee_records.last_name', 'document_types.name')
  end

  def get_expired_documents(account)
    ExpiredDocument
      .for_account(account)
      .joins(:employee_record)
      .joins(:document_type)
      .select("employee_records.id AS employee_record_id, CONCAT(employee_records.last_name, ', ', employee_records.first_name) AS employee_name, document_types.name AS document_name")
      .order('employee_records.last_name', 'document_types.name')
  end

  def get_expiring_documents(account)
    ExpiringDocument
      .for_account(account)
      .joins(:employee_record)
      .joins(:document_type)
      .select("employee_records.id AS employee_record_id, expiring_documents.days_until_expiry, CONCAT(employee_records.last_name, ', ', employee_records.first_name) AS employee_name, document_types.name AS document_name")
      .order('employee_records.last_name', 'document_types.name')
  end

  def get_past_due_or_expired_assignments(account)
    IncompleteAssignment
      .for_account(account)
      .joins(:employee_record)
      .joins(:course)
      .select("incomplete_assignments.id, employee_records.id AS employee_record_id, incomplete_assignments.status, incomplete_assignments.due_date, CONCAT(employee_records.last_name, ', ', employee_records.first_name) AS employee_name, courses.title AS course_title")
      .where("incomplete_assignments.due_date < current_date")
      .order('incomplete_assignments.due_date', 'employee_records.last_name')
  end

  def get_due_soon_or_expiring_soon_assignments(account)
    IncompleteAssignment
      .for_account(account)
      .joins(:employee_record)
      .joins(:course)
      .select("incomplete_assignments.id, employee_records.id AS employee_record_id, incomplete_assignments.status, incomplete_assignments.due_date, CONCAT(employee_records.last_name, ', ', employee_records.first_name) AS employee_name, courses.title AS course_title")
      .where("(incomplete_assignments.due_date - current_date) BETWEEN 0 AND #{Assignment::EXPIRING_SOON_THRESHOLD}")
      .order('incomplete_assignments.due_date', 'employee_records.last_name')
  end
end
