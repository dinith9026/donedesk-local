module CommonPTOEntryValidationTests
  extend ActiveSupport::Concern

  included do
    should validate_presence_of(:hours)
    should validate_presence_of(:date)
    should validate_numericality_of(:hours).is_greater_than(0).allow_nil

    test 'uniqueness_of_date_per_employee validation' do
      existing_pto_entry = pto_entries(:for_oceanview_ed)
      new_pto_entry = build(
        :pto_entry,
        employee_record: existing_pto_entry.employee_record,
        date: existing_pto_entry.date
      )

      new_pto_entry.valid?

      assert_includes new_pto_entry.errors.keys, :date
      assert_equal ['already exists for Ed Employee'], new_pto_entry.errors.messages[:date]
    end
  end
end
