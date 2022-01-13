class EmployeeDashboard
  delegate :percentage, to: :document_compliance, prefix: true
  delegate :percentage, to: :training_compliance, prefix: true

  def initialize(user)
    @user = user
    @policy = EmployeeRecordPolicy.new(user, user.employee_record || EmployeeRecord.new)
    @document_compliance = DocumentCompliance.new([user.employee_record])
    @training_compliance = TrainingCompliance.new([user.employee_record])
  end

  def when_show_compliance_stats_for_offices(&block)
    false
  end

  def when_employee_record_exists(&block)
    if @user.employee_record.present?
      yield if block_given?
    end
  end

  def when_no_employee_record_exists(&block)
    unless @user.employee_record.present?
      yield if block_given?
    end
  end

  def new_employee_record_form
    default_form_values = {
      user_id: @user.id,
      first_name: @user.first_name,
      last_name: @user.last_name,
      user: { email: @user.email }
    }

    EmployeeRecordForm
      .new(default_form_values)
      .with_policy(@policy)
      .with_context(current_account: @user.account, user: @user)
  end

  def employee_record_presenter
    opts = { show_actions: false }
    EmployeeRecordPresenter.new(@user.employee_record, @policy, opts)
  end

  private

  attr_reader :document_compliance, :training_compliance

end
