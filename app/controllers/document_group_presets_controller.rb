class DocumentGroupPresetsController < ApplicationController
  def index
    authorize DocumentGroupPreset
    @document_group_presets = DocumentGroupPreset.all
  end

  def new
    authorize DocumentGroupPreset
    @document_types = get_document_types
    @form = DocumentGroupPreset.new(applies_to: @document_types.first.applies_to)
  end

  def create
    authorize DocumentGroupPreset
    groupings = params[:document_types_groupings].to_a.map do |grouping_param|
      { id: grouping_param['id'], required: grouping_param['required'].present? || false }
    end
    @group = DocumentGroupPreset.new(
      name: document_group_preset_params[:name],
      applies_to: document_group_preset_params[:applies_to],
      document_types: groupings
    )
    @form = @group
    @document_types = get_document_types

    if @group.save
      set_flash_success_and_redirect_to(document_group_preset_path(@group))
    else
      render :new
    end
  end

  def show
    @document_group_preset = DocumentGroupPreset.find(params[:id])
    authorize @document_group_preset
    ids = @document_group_preset.document_types.map { |values| values['id'] }
    @document_type_names = DocumentType.where(id: ids).map do |document_type|
      { document_type.id => document_type.name }
    end.inject(:merge)
  end

  def edit
    @document_group_preset = DocumentGroupPreset.find(params[:id])
    @document_types = get_document_types
    authorize @document_group_preset
    @form = @document_group_preset
  end

  def update
    @document_group_preset = DocumentGroupPreset.find(params[:id])
    authorize @document_group_preset
    @document_types = get_document_types
    @form = @document_group_preset

    groupings = params[:document_types_groupings].to_a.map do |grouping_param|
      { id: grouping_param['id'], required: grouping_param['required'].present? || false }
    end

    if @document_group_preset.update(name: document_group_preset_params[:name], document_types: groupings)
      set_flash_success_and_redirect_to(document_group_preset_path(@document_group_preset))
    else
      render :edit
    end
  end

  def copy
    @document_group_preset = DocumentGroupPreset.find(params[:id])
    authorize @document_group_preset

    document_group = current_account.document_groups.build(
      name: @document_group_preset.name,
      account_id: current_account.id
    )

    @document_group_preset.document_types.each do |document_type|
      document_group.document_types_groupings.build(
        document_type_id: document_type['id'],
        required: document_type.fetch('required', false),
      )
    end

    if document_group.save
      set_flash_success_and_redirect_to(document_group_path(document_group))
    else
      error = "Looks like you already have a group with the name: " \
              "`#{@document_group_preset.name}`. Rename or delete it first, " \
              "then try adding the preset again."
      set_flash_error_and_redirect_to(document_groups_path, error)
    end
  end

  def destroy
    @document_group_preset = DocumentGroupPreset.find(params[:id])
    authorize @document_group_preset

    if @document_group_preset.is_default
      error = 'You cannot destroy the default preset because it is copied to new accounts when they are created. Note, you can safely rename it.'
      set_flash_error_and_redirect_to(document_group_presets_path, error)
    else
      @document_group_preset.destroy!
      set_flash_success_and_redirect_to(document_group_presets_path)
    end
  end

  private

  def document_group_preset_params
    params.require(:document_group_preset).permit(:name, :applies_to)
  end

  def get_document_types
    applies_to = @document_group_preset ? @document_group_preset.applies_to : params[:applies_to].presence || 'employees'
    types = DocumentType.canned

    if AppliesTo.valid?(applies_to)
      types.public_send(applies_to)
    else
      types.employees
    end
  end
end
