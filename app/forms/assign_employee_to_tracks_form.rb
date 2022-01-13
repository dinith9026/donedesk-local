class AssignEmployeeToTracksForm < ApplicationForm
  attribute :track_ids, Array

  validate :at_least_one_track

  private

  def at_least_one_track
    if track_ids.reject(&:empty?).empty?
      errors.add(:base, 'You must select at least one track')
    end
  end
end
