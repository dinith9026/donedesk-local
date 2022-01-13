class DashboardController < ApplicationController
  before_action :skip_authorization, only: [:show]

  def show
    @dashboard = Dashboard.for(current_user)
    render "dashboard/#{current_user.role}/show"
  end
end
