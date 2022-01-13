module CommonEmployeeNoteValidationTests
  extend ActiveSupport::Concern

  included do
    should validate_presence_of(:body)
  end
end
