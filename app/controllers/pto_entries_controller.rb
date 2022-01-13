class PTOEntriesController < ApplicationController
  def index
    authorize PTOEntry
    pto_entries = current_account.pto_entries.within(date_range)
    @pto_entries_presenter =
      PTOEntriesPresenter
      .new(pto_entries, current_user)
      .with_context(date_range: date_range, current_account: current_account)
  end

  def new
    employee_record = find_employee_record
    pto_entry = employee_record.pto_entries.build
    authorize pto_entry
    @form =
      PTOEntryForm
      .from_model(pto_entry)
      .with_context(employee_record: employee_record)
  end

  def create
    employee_record = find_employee_record
    pto_entry = employee_record.pto_entries.build(pto_entry_params)
    authorize pto_entry
    @form =
      PTOEntryForm
      .from_params(pto_entry_params, employee_record_id: employee_record.id)
      .with_context(employee_record: employee_record)

    if @form.valid?
      employee_record.pto_entries.create(@form.attributes)
      set_flash_success_and_redirect_to(pto_entries_path)
    else
      render :new
    end
  end

  def edit
    pto_entry = find_pto_entry
    authorize pto_entry
    @form =
      PTOEntryForm
      .from_model(pto_entry)
      .with_context(employee_record: pto_entry.employee_record)
  end

  def update
    pto_entry = find_pto_entry
    authorize pto_entry
    @form =
      PTOEntryForm
      .from_model(pto_entry)
      .with_context(employee_record: pto_entry.employee_record)
    @form.attributes = pto_entry_params.to_h

    if @form.valid?
      pto_entry.update(@form.attributes)
      set_flash_success_and_redirect_to(pto_entries_path)
    else
      render :edit
    end
  end

  def destroy
    pto_entry = find_pto_entry
    authorize pto_entry

    pto_entry.destroy!

    set_flash_success_and_redirect_to(pto_entries_path)
  end

  private

  def pto_entry_params
    params.require(:pto_entry).permit(:hours, :date)
  end

  def find_employee_record
    current_account.employee_records.find(params[:employee_record_id])
  end

  def find_pto_entry
    current_account.pto_entries.find(params[:id])
  end

  def date_range
    date_from = params[:date_from] || 1.week.ago.beginning_of_week.to_s
    date_to = params[:date_to] || 1.week.ago.end_of_week.to_s

    Date.parse(date_from).beginning_of_day..Date.parse(date_to).end_of_day
  end
end
