class UpdateLibraryDocument < ApplicationCommand
  def initialize(form, library_document, account)
    @form = form
    @library_document = library_document
    @account = account
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    attrs = @form.attributes.tap do |attributes|
      attributes[:account_id] = @form.is_canned ? nil : @account.id
    end

    @library_document.update!(attrs)

    broadcast(:ok)
  end
end
