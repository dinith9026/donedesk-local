class UpdateDocumentGroup < ApplicationCommand
  def initialize(form, document_group)
    @form = form
    @document_group = document_group
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    updated_document_group =
      transaction do
        @document_group.update!(name: @form.name)

        @form.document_types_groupings.each do |dtg_params|
          next if dtg_params.document_type_id.nil?

          existing_dtg = @document_group.document_types_groupings.find do |dtg|
            dtg_params.document_type_id == dtg.document_type_id
          end

          if existing_dtg
            existing_dtg.update(required: dtg_params.required)
          else
            DocumentTypesGrouping.create!(
              document_type_id: dtg_params.document_type_id,
              document_group_id: @document_group.id,
              required: dtg_params.required
            )
          end
        end

        existing_document_type_ids = @document_group.document_types_groupings.map(&:document_type_id)
        param_document_type_ids = @form.document_types_groupings.map(&:document_type_id)

        document_type_ids_to_delete = existing_document_type_ids - param_document_type_ids

        if document_type_ids_to_delete.any?
          document_type_ids_to_delete.each do |document_type_id|
            dtg = @document_group.document_types_groupings.find { |dtg| dtg.document_type_id == document_type_id }
            dtg.destroy!
          end
        end

        @document_group
      end

    broadcast(:ok, updated_document_group)
  end
end
