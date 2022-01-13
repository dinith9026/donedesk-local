class EmployeeRecordsController < ApplicationController
  include EmployeeRecords

  before_action :load_offices, only: [:new, :create, :edit, :update]

  def index
    authorize EmployeeRecord
    @employees = search_and_filter(current_account.employee_records)

    respond_to do |format|
      format.html do
        @employees =
          @employees
          .includes(:account, :office, :user, :documents, [document_group: [document_types_groupings: :document_type]])
          .page(params[:page])
          .per(10)

        @employee_records_presenter =
          EmployeeRecordsPresenter.new(@employees, current_user)
                                  .with_context(current_account: current_account)
        render :index
      end

      format.json do
        employees_json = @employees.map do |employee_record|
          { label: "#{employee_record.last_comma_first}" , value: employee_record.id }
        end.flatten.compact.to_json

        render json: employees_json
      end
    end
  end

  # Handles:
  # /users/:user_id/employee_records/new (for backwards compatibility)
  # /employee_records/new
  def new
    authorize current_account, :create_employee_record?
    user = params[:user_id] ? current_account.users.find(params[:user_id]) : nil
    default_form_values = {
      user_id: user&.id,
      first_name: user&.first_name,
      last_name: user&.last_name,
      user: { email: user&.email }
    }

    # Note: employees don't use this route, see EmployeeDashboard.new_employee_record_form
    @form = EmployeeRecordForm.new(default_form_values)
            .with_policy(policy(EmployeeRecord.new))
            .with_context(current_account: current_account, user: user)
  end

  def create
    user =
      if current_user.employee?
        current_user
      elsif employee_record_params[:user_id]
        # Prevent malicous user from passing just ANY user_id
        current_account.users.find(employee_record_params[:user_id])
      else
        nil
      end

    @form = EmployeeRecordForm
            .from_params(employee_record_params, user_id: user&.id)
            .with_policy(policy(EmployeeRecord.new))
            .with_context(current_account: current_account, user: user)

    authorize current_account, :create_employee_record?

    CreateEmployeeRecord.call(current_account, @form) do
      on(:ok) do |id|
        if current_user.employee?
          set_flash_success_and_redirect_to(dashboard_url)
        else
          set_flash_success_and_redirect_to(employee_records_url)
        end

      end
      on(:invalid_invite) do |form|
        @form = form
        set_flash_error_and_render(:new)
      end
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def show
    @employee_record = find_employee_record
    @employee_record_presenter =
      EmployeeRecordPresenter
      .new(@employee_record, policy(@employee_record))
      .with_context(current_account: current_account)
    authorize @employee_record
  end

  def edit
    @employee_record = find_employee_record
    @office = @employee_record.office
    @form = EmployeeRecordForm
            .from_model(@employee_record)
            .with_policy(policy(@employee_record))
            .with_context(current_account: current_account, user: @employee_record.user)
    authorize @employee_record
  end

  def update
    @employee_record = find_employee_record
    @form = EmployeeRecordForm
            .from_model(@employee_record)
            .with_policy(policy(@employee_record))
            .with_context(current_account: current_account)
    @form.attributes = employee_record_params.to_h
    authorize @employee_record

    UpdateEmployeeRecord.call(@form, @employee_record) do
      on(:ok) { |employee_record| set_flash_success_and_redirect_to(url_after_update(employee_record)) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def create_assignments
    employee_record = find_employee_record
    authorize employee_record, :assign_course?
    form = AssignEmployeeToCoursesForm.new(assignment_params.to_h)

    AssignEmployeeToCourses.call(form, employee_record) do
      on(:ok)      { |emp_rec| set_flash_success_and_redirect_to(emp_rec) }
      on(:invalid) { |emp_rec, errors| set_flash_error_and_redirect_to(emp_rec, errors) }
    end
  end

  def create_assigned_tracks
    employee_record = find_employee_record
    authorize employee_record, :assign_track?
    form = AssignEmployeeToTracksForm.new(assigned_track_params.to_h)

    AssignEmployeeToTracks.call(form, employee_record) do
      on(:ok)      { |emp_rec| set_flash_success_and_redirect_to(emp_rec) }
      on(:invalid) { |emp_rec, errors| set_flash_error_and_redirect_to(emp_rec, errors) }
    end
  end

  def suspend
    employee_record = find_employee_record
    authorize employee_record

    SuspendEmployee.call(employee_record) do
      on(:ok) { set_flash_success_and_redirect_to(smart_back_path) }
    end
  end

  def unsuspend
    employee_record = find_employee_record
    authorize employee_record

    UnsuspendEmployee.call(employee_record) do
      on(:ok) { |er| set_flash_success_and_redirect_to(smart_back_path) }
    end
  end

  def terminate
    employee_record = find_employee_record
    authorize employee_record

    TerminateEmployee.call(employee_record) do
      on(:ok) { set_flash_success_and_redirect_to(smart_back_path) }
    end
  end

  def rehire
    employee_record = find_employee_record
    authorize employee_record

    RehireEmployee.call(employee_record) do
      on(:ok) { |er| set_flash_success_and_redirect_to(smart_back_path) }
    end
  end

  private

  def employee_record_params
    params.require(:employee_record)
          .permit(policy(@employee_record || EmployeeRecord.new).permitted_attributes)
  end

  def assignment_params
    params.permit(course_ids: [])
  end

  def assigned_track_params
    params.permit(track_ids: [])
  end

  def load_offices
    @offices = ListOfficesForAccount.new(current_account.id).query
  end

  def find_employee_record
    current_account
      .employee_records
      .includes([[document_types_groupings: :document_type], [assignments: [:course, :exams]]])
      .find(params[:id])
  end

  def url_after_update(employee_record)
    redirect_url(employee_record)
  end

  def redirect_url(employee_record)
    if current_user.has_role?(:employee)
      dashboard_url
    else
      employee_record_url(employee_record)
    end
  end
end
