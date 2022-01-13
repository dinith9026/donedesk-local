module CommonTimeEntryValidations
  extend ActiveSupport::Concern

  included do
    validates :entry_type, :occurred_at, presence: true
    validate :entry_type_is_allowed,
      if: -> record { record.employee_record.present? && record.occurred_at.present? }

    private

    def entry_type_is_allowed
      if !time_card.valid_entry?(self)
        errors.add(:entry_type, "`#{self.entry_type}` is not allowed")
      end
    end

    def time_card
      TimeCard.new(employee_record, occurred_at)
    end
  end
end
