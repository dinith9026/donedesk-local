class ApplicationJob < ActiveJob::Base
  rescue_from(StandardError) do |exception|
    Raven.capture_exception(exception)
  end
end
