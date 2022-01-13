require 'test_helper'

class TimeSheetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    date_range = 1.day.ago.to_date..Date.current
    @employee = users(:employee)
    @other_employee = users(:another_employee)
    @time_sheet = TimeSheet.new(@employee.employee_record, date_range)
    @other_time_sheet = TimeSheet.new(@other_employee.employee_record, date_range)
  end

  describe '#index' do
    it_requires_authenticated_user { get time_sheets_url }

    test 'when requested format is CSV' do
      date_from = '2018-08-06'
      date_to = '2018-08-12'
      user = users(:account_manager)
      expected_disposition =
        "attachment; filename=\"time-sheets-#{date_from}-to-#{date_to}.csv\""

      get time_sheets_url(as: user, date_from: date_from, date_to: date_to, format: :csv)

      assert_response :success
      assert_equal 'text/csv', response.header['Content-Type']
      assert_equal expected_disposition, response.headers['Content-Disposition']
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when no date is given' do
          user = users(role)

          get time_sheets_url(as: user)

          assert_response :success
          assert_includes assigns, 'time_sheets_presenter'
          assert_includes assigns[:time_sheets_presenter], @time_sheet
          refute_includes assigns[:time_sheets_presenter], @other_time_sheet
        end

        test 'when date is given' do
          user = users(role)
          params = { date_from: 1.day.ago.to_date, date_to: Date.current }

          get time_sheets_url(as: user), params: params

          assert_response :success
        end

        test 'when office that does NOT track time is given' do
          user = users(role)
          office = offices(:oceanview_oh)

          get time_sheets_url(as: user), params: { office_id: office.id }

          assert_redirects_with_not_found_error
        end
      end
    end

    test 'for employee' do
      get time_sheets_url(as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end
end
