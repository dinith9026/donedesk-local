class StatusController < ActionController::Base
  def index
    render json: DoneDesk::HealthCheck.new.execute
  end
end
