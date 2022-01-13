module Acceptance
  module Asserts
    def assert_time_entry(time_entry)
      occurred_at = time_entry.occurred_at_in_zone.strftime("%I:%M %p %Z")

      assert_content time_entry.employee_record_full_name
      assert_content time_entry.entry_type.humanize
      assert_content occurred_at
    end

    def assert_time_card(date, regular_time, break_time, pto_time)
      assert_content date.strftime('%a, %b %-e, %Y')
      assert_content regular_time.to_s
      assert_content break_time.to_s
      assert_content pto_time.to_s
    end
  end
end
