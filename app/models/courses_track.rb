class CoursesTrack < ApplicationRecord
  belongs_to :course
  belongs_to :track

  acts_as_list scope: :track
end
