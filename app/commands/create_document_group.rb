class CreateDocumentGroup < ApplicationCommand
  def initialize(form)
    @form = form
  end

  def call
    return broadcast(:invalid) if form.invalid?

    document_group =
      transaction do
        create_document_group
      end

    broadcast(:ok, document_group)
  end

  private

  attr_reader :form

  def create_document_group
    document_group = DocumentGroup.new(name: form.name, applies_to: form.applies_to, account_id: form.account_id)

    form.document_types_groupings.each do |dtg|
      document_group.document_types_groupings.build(dtg.attributes)
    end

    document_group.save!

    document_group
  end
end
