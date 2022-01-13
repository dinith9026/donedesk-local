module CommonCourseValidations
  extend ActiveSupport::Concern

  included do
    validates :title, :compliance_expiration_in_days,
              :max_test_retakes, :passing_threshold_percentage,
                presence: true
    validates :days_due_within,
      numericality: { greater_than: 0, allow_nil: true, allow_blank: true }
  end
end
