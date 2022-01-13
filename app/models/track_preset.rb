class TrackPreset < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :courses, presence: true
end
