class TrackForm < ApplicationForm
  attribute :account_id, String
  attribute :name, String
  attribute :course_ids, Array

  validates :name, presence: true
  validate :name_is_unique_for_account
  validate :at_least_one_course

  def courses
    context.courses
  end

  def new_form_action
    tracks_path
  end

  def edit_form_action
    track_path(id: id)
  end

  def name_is_unique_for_account
    if Track.where(name: name, account_id: account_id).where.not(id: id).any?
      errors.add(:name, 'already taken')
    end
  end

  private

  def at_least_one_course
    if course_ids.length == 0
      errors.add(:base, 'A track must have at least 1 course')
    end
  end
end
