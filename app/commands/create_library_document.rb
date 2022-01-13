class CreateLibraryDocument < ApplicationCommand
  def initialize(form, account)
    @form = form
    @account = account
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    attrs = @form.attributes

    if @form.is_canned?
      attrs[:account_id] = nil
    end

    LibraryDocument.create!(attrs)

    broadcast(:ok)
  end
end
