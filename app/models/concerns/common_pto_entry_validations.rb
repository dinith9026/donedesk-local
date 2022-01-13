module CommonPTOEntryValidations
  extend ActiveSupport::Concern

  included do
    validates :hours, :date, presence: true
    validates :hours, numericality: { greater_than: 0, allow_blank: true }
    validate :uniqueness_of_date_per_employee

    private

    def uniqueness_of_date_per_employee
      pto_entry = PTOEntry.find_by(date: date, employee_record_id: employee_record_id)

      if pto_entry && (pto_entry.id != id || id.nil?)
        errors.add(:date, "already exists for #{employee_record.full_name}")
      end
    end
  end
end
