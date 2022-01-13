module TimeZonable
  extend ActiveSupport::Concern

  included do
    around_action :set_time_zone, if: :current_user
  end

  private

  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
