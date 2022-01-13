class TimeCardPolicy < ApplicationPolicy
  def index?
    user.employee? && user.tracks_time?
  end
end
