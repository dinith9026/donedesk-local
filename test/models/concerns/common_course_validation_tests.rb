module CommonCourseValidationTests
  extend ActiveSupport::Concern

  included do
    should validate_presence_of(:title)
    should validate_presence_of(:compliance_expiration_in_days)
    should validate_presence_of(:max_test_retakes)
    should validate_presence_of(:passing_threshold_percentage)
    should validate_numericality_of(:days_due_within).is_greater_than(0).allow_nil
  end
end
