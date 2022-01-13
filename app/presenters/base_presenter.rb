class BasePresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Context
  include Rails.application.routes.url_helpers

  include PresenterHelpers
end
