require 'test_helper'

class TimeCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = users(:employee)
    @employee_record = employee_records(:ed)
    @other_employee_record = employee_records(:ellen)
  end

  describe '#index' do
    it_requires_authenticated_user do
      get employee_record_time_cards_url(@employee_record)
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when employee record does NOT belong to their account' do
          user = users(role)

          get employee_record_time_cards_url(@other_employee_record, as: user)

          assert_redirects_with_not_found_error
        end

        describe 'when employee record belongs to their account' do
          test 'when no dates are given' do
            user = users(role)

            get employee_record_time_cards_url(@employee_record, as: user)

            assert_response :success
          end

          test 'when invalid dates are given' do
            user = users(role)

            get employee_record_time_cards_url(@employee_record, as: user),
              params: { date_from: 'invalid', date_to: 'invalid' }

            assert_redirects_with_flash_error(
              employee_record_time_cards_url(@employee_record)
            )
          end

          test 'when valid dates are given' do
            user = users(role)

            get employee_record_time_cards_url(@employee_record, as: user),
              params: { date_from: 1.day.ago.to_date, date_to: Date.current }

            assert_response :success
          end

        end
      end
    end

    test 'for employee' do
      get time_cards_url(@employee_record, as: @employee)

      assert_response :success
    end
  end
end
