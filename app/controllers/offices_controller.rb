class OfficesController < ApplicationController
  include EmployeeRecords

  def index
    authorize Office
    offices = ListOfficesForAccount.new(current_account.id).query
    @offices_presenter = OfficesPresenter.new(offices, current_user)
  end

  def show
    office = find_office
    authorize office

    employee_records =
      search_and_filter(office.employee_records)
      .includes(:account, :office, :user, :documents, [document_group: [document_types_groupings: :document_type]])
      .page(params[:page])
      .per(10)

    @contacts =
      Contact.all
      .page(params[:page])
      .per(10)

    employee_records_presenter =
      EmployeeRecordsPresenter.new(employee_records, current_user)
                              .with_context(current_account: current_account)

    @office_presenter =
      OfficePresenter
      .new(office, policy(office))
      .with_context(employee_records_presenter: employee_records_presenter)
  end

  def new
    office = current_account.offices.build
    authorize office
    @form =
      OfficeForm
      .from_model(office)
      .with_policy(policy(office))
      .with_context(current_account: current_account)
  end

  def create
    office = current_account.offices.build
    authorize office
    @form =
      OfficeForm
      .from_params(params, account_id: current_account.id)
      .with_policy(policy(office))
      .with_context(current_account: current_account)

    CreateOffice.call(@form) do
      on(:ok)      { |office| set_flash_success_and_redirect_to(office) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def edit
    office = find_office
    authorize office

    @form = OfficeForm.from_model(office).with_policy(policy(office)).with_context(current_account: current_account)
  end

  def update
    office = find_office
    authorize office

    @form =
      OfficeForm
      .from_params(params, account_id: current_account.id)
      .with_policy(policy(office))
      .with_context(current_account: current_account)

    UpdateOffice.call(@form) do
      on(:ok)      { |office| set_flash_success_and_redirect_to(office) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def destroy
    office = find_office
    authorize office

    office.destroy!

    set_flash_success_and_redirect_to(offices_url)
  end

  private

  def find_office
    FindOfficeForAccount.new(current_account.id, params[:id]).query
  end
end
