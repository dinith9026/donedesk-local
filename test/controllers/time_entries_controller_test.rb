require 'test_helper'

class TimeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @super_admin = users(:super_admin)
    @account_owner = users(:account_owner)
    @account_manager = users(:account_manager)
    @employee = users(:employee)
    @employee_record = employee_records(:ed)
    @coworker_employee_record = employee_records(:eric)
    @other_employee_record = employee_records(:ellen)
    @account = @employee_record.account
    Time.zone = @employee_record.office_time_zone
  end

  teardown do
    TimeEntry.destroy_all
    Time.zone = 'UTC'
  end

  describe '#index' do
    before do
      @yesterday = 1.day.ago.to_date
      @time_entry = clock_in(@employee_record, '9:00 AM')
      @old_time_entry = clock_in(@employee_record, @yesterday)
      @other_time_entry = clock_in(@other_employee_record, '9:00 AM')
    end

    describe '/employee_records/:employee_record_id/time_entries' do
      it_requires_authenticated_user do
        get employee_record_time_entries_url(@employee_record)
      end

      [:account_owner, :account_manager].each do |role|
        describe "for #{role}" do
          test 'when date is given' do
            user = users(role)
            params = { date: @yesterday }

            get employee_record_time_entries_url(@employee_record, as: user),
              params: params

            assert_response :success
            assert_includes assigns.keys, 'time_entries_presenter'
            assert_equal 1, assigns[:time_entries_presenter].count
            refute_includes assigns[:time_entries_presenter], @time_entry
            assert_includes assigns[:time_entries_presenter], @old_time_entry
          end

          test 'when employee record does NOT belong to their account' do
            get employee_record_time_entries_url(@other_employee_record,
                                                 as: users(role))

            assert_redirects_with_not_found_error
          end

          test 'when employee record belongs to their account' do
            get employee_record_time_entries_url(@employee_record, as: users(role))

            assert_response :success
            assert_includes assigns.keys, 'time_entries_presenter'
            assert_equal 1, assigns[:time_entries_presenter].count
            assert_includes assigns[:time_entries_presenter], @time_entry
            refute_includes assigns[:time_entries_presenter], @old_time_entry
          end
        end
      end

      describe 'for employee' do
        test 'when employee record is NOT their own' do
          get employee_record_time_entries_url(@coworker_employee_record,
                                               as: @employee)

          assert_redirects_with_not_authorized_error
        end

        test 'when employee record is their own' do
          get employee_record_time_entries_url(@employee_record, as: @employee)

          assert_response :success
          assert_includes assigns.keys, 'time_entries_presenter'
          assert_equal 1, assigns[:time_entries_presenter].count
          assert_includes assigns[:time_entries_presenter], @time_entry
          refute_includes assigns[:time_entries_presenter], @old_time_entry
        end
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user do
      post employee_record_time_entries_url(@employee_record)
    end

    test 'for super admin' do
      put current_account_url(as: @super_admin, current_account_name: @account.name)

      assert_difference 'TimeEntry.count', 1 do
        post employee_record_time_entries_url(@employee_record, as: @super_admin),
          params: { time_entry: valid_params }
      end
      assert_equal '2018-10-25 09:00:00 -0500', last_time_entry.occurred_at.to_s
      assert_redirects_with_flash_success(root_path)
    end

    describe 'for account owner' do
      test 'when employee record does NOT belong to their account' do
        assert_no_difference 'TimeEntry.count' do
          post employee_record_time_entries_url(@other_employee_record, as: @account_owner),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_not_found_error
      end

      test 'when employee record belongs to their account' do
        assert_difference 'TimeEntry.count', 1 do
          post employee_record_time_entries_url(@employee_record, as: @account_owner),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_flash_success(root_path)
      end
    end

    describe 'for account manager' do
      test 'when employee record does NOT belong to their account' do
        assert_no_difference 'TimeEntry.count' do
          post employee_record_time_entries_url(@other_employee_record, as: @account_manager),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_not_found_error
      end

      test 'when employee record belongs to their account' do
        assert_difference 'TimeEntry.count', 1 do
          post employee_record_time_entries_url(@employee_record, as: @account_manager),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_flash_success(root_path)
      end

      test 'when employee record is their own' do
        assert_difference 'TimeEntry.count', 1 do
          post employee_record_time_entries_url(@account_manager.employee_record, as: @account_manager),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_flash_success(logout_or_continue_page_path)
      end
    end

    describe 'for employee' do
      test 'when employee record is NOT their own' do
        assert_no_difference 'TimeEntry.count' do
          post employee_record_time_entries_url(@coworker_employee_record, as: @employee),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_not_authorized_error
      end

      test 'when employee record is their own' do
        assert_difference 'TimeEntry.count', 1 do
          post employee_record_time_entries_url(@employee.employee_record, as: @employee),
            params: { time_entry: valid_params }
        end
        assert_redirects_with_flash_success(logout_or_continue_page_path)
      end
    end
  end

  describe '#edit' do
    before do
      @time_entry = clock_in(@employee_record)
      @other_time_entry = clock_in(@other_employee_record)
    end

    it_requires_authenticated_user { get edit_time_entry_url(@time_entry) }

    describe 'for account manager' do
      test 'when record does NOT belong to their account' do
        get edit_time_entry_url(@other_time_entry, as: @account_manager)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account' do
        get edit_time_entry_url(@time_entry, as: @account_manager)

        assert_response :success
        assert_includes assigns.keys, 'form'
      end
    end

    test 'for employee' do
      get edit_time_entry_url(@time_entry, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    before do
      @time_entry = clock_in(@employee_record)
      @other_time_entry = clock_in(@other_employee_record)
    end

    it_requires_authenticated_user { put time_entry_url(@time_entry) }

    describe 'for account manager' do
      test 'when record does NOT belong to their account' do
        put time_entry_url(@other_time_entry, as: @account_manager)

        assert_redirects_with_not_found_error
      end

      describe 'when record belongs to their account' do
        test 'when params are INVALID' do
          new_occurred_at = '01/01/2018 9:00 AM'
          invalid_params =
            valid_params.merge(occurred_at: new_occurred_at, entry_type: '')

          put time_entry_url(@time_entry, as: @account_manager),
            params: { time_entry: invalid_params }

          assert_response :success
          assert_template :edit
          assert_includes assigns.keys, 'form'
          refute_equal new_occurred_at.to_i, @time_entry.reload.occurred_at.to_i
        end

        test 'when params are VALID' do
          new_occurred_at = '01/01/2018 9:00 AM'
          expected_occurred_at =
            Time.use_zone(@employee_record.office_time_zone) do
              Time.zone.parse(new_occurred_at)
            end

          put time_entry_url(@time_entry, as: @account_manager),
            params: { time_entry: valid_params.merge(occurred_at: new_occurred_at) }

          assert_response :redirect
          assert_equal expected_occurred_at.utc, @time_entry.reload.occurred_at.utc
        end
      end
    end

    test 'for employee' do
      put time_entry_url(@time_entry, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    before do
      @time_entry = clock_in(@employee_record)
      @other_time_entry = clock_in(@other_employee_record)
    end

    it_requires_authenticated_user { delete time_entry_url(@time_entry) }

    describe 'for account manager' do
      test 'when record does NOT belong to their account' do
        assert_no_difference 'TimeEntry.count' do
          delete time_entry_url(@other_time_entry, as: @account_manager)
        end
        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account' do
        assert_difference 'TimeEntry.count', -1 do
          delete time_entry_url(@time_entry, as: @account_manager)
        end
        assert_response :redirect
      end
    end

    test 'for employee' do
      delete time_entry_url(@time_entry, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    attributes_for(:time_entry).merge(occurred_at: '10/25/2018 9:00 AM')
  end

  def last_time_entry
    TimeEntry.order(:created_at).last
  end
end
