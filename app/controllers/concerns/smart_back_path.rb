module SmartBackPath
  extend ActiveSupport::Concern

  included do
    after_action :set_back_path, only: [:index, :show], if: -> { request.format.html? }
    helper_method :smart_back_path
  end

  def smart_back_path
    session&.fetch(:back_path, nil).presence || root_path
  end

  private

  def set_back_path
    session[:back_path] = request.fullpath
  end
end
