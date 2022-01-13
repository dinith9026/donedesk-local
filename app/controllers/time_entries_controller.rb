class TimeEntriesController < ApplicationController
  class MissingEmployeeRecord < StandardError; end

  rescue_from MissingEmployeeRecord, with: :missing_employee_record

  def index
    employee_record = find_employee_record
    time_zone = employee_record.office_time_zone
    date = date_param(time_zone) || Time.now.in_time_zone(time_zone).to_date
    time_entries = employee_record.time_entries.for_day(date, time_zone)

    authorize employee_record, :list_time_entries?

    @time_entries_presenter =
      TimeEntriesPresenter
      .new(time_entries, current_user, policy(employee_record))
      .with_context(date: date, employee_record: employee_record, current_account: current_account)
  end

  def new
    employee_record = find_employee_record
    time_entry = employee_record.time_entries.build
    authorize time_entry
    @form = TimeEntryForm.new.with_context(employee_record: employee_record)
  end

  def create
    employee_record = find_employee_record
    time_entry = Time.use_zone(employee_record.office_time_zone) do
      employee_record.time_entries.build(time_entry_params)
    end
    authorize time_entry
    @form =
      TimeEntryForm
      .from_model(time_entry)
      .with_context(employee_record: employee_record)

    if @form.valid?
      Time.use_zone(employee_record.office_time_zone) do
        employee_record.time_entries.create!(@form.attributes)
      end
      set_flash_success_and_redirect_to(after_create_path)
    else
      render :new
    end
  end

  def edit
    time_entry = find_time_entry
    authorize time_entry
    @form =
      TimeEntryForm
      .from_model(time_entry)
      .with_context(employee_record: time_entry.employee_record)
  end

  def update
    time_entry = find_time_entry
    employee_record = time_entry.employee_record
    authorize time_entry
    @form =
      TimeEntryForm
      .from_model(time_entry)
      .with_context(employee_record: employee_record)
    @form.attributes = time_entry_params.to_h

    if @form.valid?
      Time.use_zone(employee_record.office_time_zone) do
        time_entry.update(@form.attributes)
      end
      set_flash_success_and_redirect_to(smart_back_path)
    else
      render :edit
    end
  end

  def destroy
    time_entry = find_time_entry
    authorize time_entry

    time_entry.destroy!

    set_flash_success_and_redirect_to(smart_back_path)
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(policy(TimeEntry).permitted_attributes)
  end

  def find_employee_record
    current_account
      .employee_records
      .eager_load([{user: :account}])
      .find(employee_record_id)
  end

  def find_time_entry
    current_account.time_entries.find(params[:id])
  end

  def employee_record_id
    id = params[:employee_record_id].presence || params.dig(:time_entry, :employee_record_id).presence || current_user&.employee_record_id

    if id
      id
    else
      raise MissingEmployeeRecord
    end
  end

  def missing_employee_record
    redirect_to smart_back_path,
      flash: { error: "#{current_user.full_name} does not have an employee record" }
  end

  def date_param(time_zone)
    if params[:date]
      params[:date].to_date
    else
      Time.now.in_time_zone(time_zone).to_date
    end
  end

  def after_create_path
    if current_user&.employee_record_id == employee_record_id
      logout_or_continue_page_path
    else
      smart_back_path
    end
  end
end
