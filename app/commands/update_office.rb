class UpdateOffice < ApplicationCommand
  def initialize(form)
    @form = form
  end

  def call
    return broadcast(:invalid) if form.invalid?

    transaction do
      office = update_office
      broadcast(:ok, office)
    end
  end

  private

  attr_reader :form

  def update_office
    office = Office.find(form.id)
    office.update!(form.attributes)
    office
  end
end
