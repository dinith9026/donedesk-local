class CreateDocumentType < ApplicationCommand
  def initialize(form, account)
    @form = form
    @account = account
  end

  def call
    return broadcast(:invalid, @form) if form.invalid?

    document_type =
      transaction do
        create_document_type
      end

    broadcast(:ok, document_type)
  end

  private

  attr_reader :form, :account

  def create_document_type
    attrs = form.attributes

    if form.is_canned?
      attrs[:account_id] = nil
    else
      attrs[:account_id] = @account.id
    end

    DocumentType.create!(attrs)
  end
end
