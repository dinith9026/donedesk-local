class DocumentGroupsController < ApplicationController
  def index
    authorize DocumentGroup
    document_groups =
      current_account
      .document_groups
      .includes(:employee_records, :document_types_groupings)
      .order(:name)

    presets = DocumentGroupPreset.all

    @document_groups_presenter = DocumentGroupsPresenter.new(
      document_groups,
      current_user,
      policy(DocumentGroup)
    ).with_context(presets: presets)
  end

  def new
    authorize DocumentGroup
    @form = build_document_group_form
  end

  def create
    authorize DocumentGroup
    @form = build_document_group_form(document_group_params)

    CreateDocumentGroup.call(@form) do
      on(:ok)      { |group| set_flash_success_and_redirect_to(group) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def show
    document_group =
      current_account
      .document_groups
      .includes(document_types_groupings: :document_type)
      .order('document_types.name')
      .find(params[:id])
    authorize document_group

    unassigned_employees =
      current_account
      .active_employee_records
      .where.not(document_group_id: document_group.id)

    unassigned_offices =
      current_account
      .offices
      .where.not(document_group_id: document_group.id)

    @document_group_presenter = DocumentGroupPresenter.new(
      document_group,
      policy(document_group)
    ).with_context(unassigned_employees: unassigned_employees, unassigned_offices: unassigned_offices)
  end

  def edit
    @document_group =
      current_account
      .document_groups
      .includes(document_types_groupings: :document_type)
      .find(params[:id])
    authorize @document_group

    @form = build_document_group_form(@document_group)
  end

  def update
    @document_group = current_account.document_groups.find(params[:id])
    authorize @document_group

    @form = build_document_group_form(@document_group)
    @form.attributes = document_group_params.to_h

    UpdateDocumentGroup.call(@form, @document_group) do
      on(:ok) { |group| set_flash_success_and_redirect_to(group) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def assign
    @document_group = current_account.document_groups.find(params[:id])
    authorize @document_group

    if @document_group.applies_to == 'employees'
      employee_records = current_account.employee_records.where(id: params[:employee_record_ids])

      if employee_records.any?
        employee_records.update_all(document_group_id: @document_group.id)
        set_flash_success_and_redirect_to(document_group_path(@document_group))
      else
        error = 'You did not select any employees!'
        set_flash_error_and_redirect_to(document_group_path(@document_group), error)
      end
    elsif @document_group.applies_to == 'offices'
      offices = current_account.offices.where(id: params[:office_ids])

      if offices.any?
        offices.update_all(document_group_id: @document_group.id)
        set_flash_success_and_redirect_to(document_group_path(@document_group))
      else
        error = 'You did not select any offices!'
        set_flash_error_and_redirect_to(document_group_path(@document_group), error)
      end
    else
      raise "Unhandled value for `document_group.applies_to`: `#{@document_group.applies_to}`"
    end
  end

  def copy
    @document_group =
      current_account
      .document_groups
      .includes(document_types_groupings: :document_type)
      .find(params[:id])
    authorize @document_group

    @form = build_document_group_form(@document_group)
    @form.name = nil
  end

  def reassign
    @document_group = current_account.document_groups.includes(:employee_records).find(params[:id])
    @all_groups = current_account.document_groups.reject { |document_group| @document_group.id == document_group.id }
    authorize @document_group

    document_groups = current_account.document_groups

    if @document_group.applies_to == 'employees'
      document_groups = document_groups.for_employees
    elsif @document_group.applies_to == 'offices'
      document_groups = document_groups.for_offices
    else
      raise "Unhandled value for `document_group.applies_to`: `#{@document_group.applies_to}`"
    end

    if document_groups.count == 1
      warning = "You can only delete this document group if you have another group " \
              "to which you can reassign the employees. Create another group first, " \
              "then you can delete this group."
      set_flash_warning_and_redirect_to(smart_back_path, warning)
    else
      render :reassign
    end
  end

  def destroy
    @document_group = current_account.document_groups.includes(:employee_records).find(params[:id])
    authorize @document_group

    if @document_group.employee_records.any?
      if params[:group_id].present?
        new_document_group = current_account.document_groups.includes(:employee_records).find(params[:group_id])
        @document_group.employee_records.update_all(document_group_id: new_document_group.id)
      else
        redirect_to reassign_document_group_path(@document_group)
        return
      end
    end

    @document_group.destroy!

    set_flash_success_and_redirect_to(document_groups_path(applies_to: @document_group.applies_to))
  end

  private

  def document_group_params
    params.require(:document_group).permit(:name, :applies_to, document_types_groupings: [:document_type_id, :required])
  end

  def build_document_group_form(params_or_model = nil)
    form = DocumentGroupForm

    form =
      if params_or_model.nil?
        form.new(applies_to: params[:applies_to] || 'employees')
      elsif params_or_model.is_a?(DocumentGroup)
        form.from_model(params_or_model)
      elsif params_or_model.is_a?(ActionController::Parameters)
        form.from_params(params_or_model)
      else
        raise "Expected `nil`, `DocumentGroup` or `ActionController::Parameters`, but got: #{params_or_model.inspect}"
      end

    form.account_id = current_account.id
    document_types = get_document_types(form.applies_to)
    form.with_context(document_types: document_types)
  end

  def get_document_types(applies_to)
    types = ListDocumentTypesForAccount.new(current_account).query

    if AppliesTo.valid?(applies_to)
      types.public_send(applies_to)
    else
      types.employees
    end
  end
end
