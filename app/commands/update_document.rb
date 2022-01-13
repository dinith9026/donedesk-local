class UpdateDocument < ApplicationCommand
  def initialize(form, document)
    @form = form
    @document = document
  end

  def call
    return broadcast(:invalid) if form.invalid?
    transaction do
      update_document
    end
    broadcast(:ok)
  end

  private

  attr_reader :form, :document

  def update_document
    document.update!(form.attributes)
  end
end