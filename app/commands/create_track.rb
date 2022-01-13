class CreateTrack < ApplicationCommand
  def initialize(form)
    @form = form
  end

  def call
    return broadcast(:invalid) if form.invalid?

    track =
      transaction do
        Track.create!(form.attributes)
      end

    broadcast(:ok, track)
  end

  private

  attr_reader :form
end
