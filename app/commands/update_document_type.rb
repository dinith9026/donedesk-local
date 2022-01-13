class UpdateDocumentType < ApplicationCommand
  def initialize(form, document_type, account)
    @form = form
    @document_type = document_type
    @account = account
  end

  def call
    return broadcast(:invalid) if form.invalid?
    transaction do
      update_document_type
    end
    broadcast(:ok)
  end

  private

  attr_reader :form, :document_type

  def update_document_type
    attrs = form.attributes

    if form.is_canned?
      attrs[:account_id] = nil
    else
      attrs[:account_id] = @account.id
    end

    document_type.update!(attrs)
  end
end
