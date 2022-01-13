class SyncName < ApplicationCommand
  def initialize(newer:, older:)
    @newer = newer
    @older = older
  end

  def call
    attrs_to_update = {
      first_name: @newer.first_name,
      last_name: @newer.last_name
    }.select do |field, newer_value|
      newer_value != @older.public_send(field)
    end

    if attrs_to_update.any?
      @older.update!(attrs_to_update)
    end

    broadcast(:ok)
  end
end
