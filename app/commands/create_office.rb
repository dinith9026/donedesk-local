class CreateOffice < ApplicationCommand
  def initialize(form)
    @form = form
  end

  def call
    return broadcast(:invalid) if form.invalid?

    transaction do
      office = create_office
      broadcast(:ok, office)
    end
  end

  private

  attr_reader :form

  def create_office
    Office.create!(form.attributes)
  end
end
