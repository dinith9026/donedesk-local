require 'test_helper'

class PTOEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_manager = users(:account_manager)
    @employee = users(:employee)
    @employee_record = employee_records(:ed)
    @other_employee_record = employee_records(:ellen)
    @pto_entry = pto_entries(:for_oceanview_ed)
    @other_pto_entry = pto_entries(:for_brookside_ellen)
  end

  describe '#index' do
    it_requires_authenticated_user { get pto_entries_url }

    test 'for account manager' do
      get pto_entries_url(as: @account_manager),
        params: { date_from: @pto_entry.date, date_to: @pto_entry.date }

      assert_response :success
      assert_includes assigns.keys, 'pto_entries_presenter'
      assert_equal 1, assigns[:pto_entries_presenter].count
      assert_includes assigns[:pto_entries_presenter], @pto_entry
      refute_includes assigns[:pto_entries_presenter], @other_pto_entry
    end

    test 'for employee' do
      get pto_entries_url(as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user do
      get new_employee_record_pto_entry_url(@employee_record)
    end

    describe 'for account manager' do
      test 'when employee record does NOT belong to their account' do
        get new_employee_record_pto_entry_url(@other_employee_record,
                                              as: @account_manager)

        assert_redirects_with_not_found_error
      end

      test 'when employee record belongs to their account' do
        get new_employee_record_pto_entry_url(@employee_record, as: @account_manager)

        assert_response :success
        assert_includes assigns.keys, 'form'
      end
    end

    test 'for employee' do
      get new_employee_record_pto_entry_url(@employee_record, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user do
      post employee_record_pto_entries_url(@employee_record)
    end

    describe 'for account manager' do
      test 'when employee record does NOT belong to their account' do
        assert_no_difference 'PTOEntry.count' do
          post employee_record_pto_entries_url(@other_employee_record, as: @account_manager),
            params: { pto_entry: valid_params }
        end
        assert_redirects_with_not_found_error
      end

      describe 'when employee record belongs to their account' do
        test 'when params are invalid' do
          assert_no_difference 'PTOEntry.count', 1 do
            post employee_record_pto_entries_url(@employee_record, as: @account_manager),
              params: { pto_entry: { hours: nil } }
          end
          assert_template :new
        end

        test 'when params are valid' do
          assert_difference 'PTOEntry.count', 1 do
            post employee_record_pto_entries_url(@employee_record, as: @account_manager),
              params: { pto_entry: valid_params }
          end
          assert_redirects_with_flash_success(pto_entries_url)
        end
      end

      test 'for employee' do
        assert_no_difference 'PTOEntry.count', 1 do
          post employee_record_pto_entries_url(@employee_record, as: @employee),
                params: { pto_entry: valid_params }
        end
        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_pto_entry_url(@pto_entry) }

    describe 'for account manager' do
      test 'when pto record does NOT belong to their account' do
        get edit_pto_entry_url(@other_pto_entry, as: @account_manager)

        assert_redirects_with_not_found_error
      end

      test 'when pto record belongs to their account' do
        get edit_pto_entry_url(@pto_entry, as: @account_manager)

        assert_response :success
        assert_includes assigns.keys, 'form'
      end
    end

    test 'for employee' do
      get edit_pto_entry_url(@pto_entry, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put pto_entry_url(@pto_entry) }

    describe 'for account manager' do
      test 'when pto record does NOT belong to their account' do
        put pto_entry_url(@other_pto_entry, as: @account_manager)

        assert_redirects_with_not_found_error
      end

      describe 'when pto record belongs to their account' do
        test 'when params are INVALID' do
          new_hours = @pto_entry.hours + 1

          put pto_entry_url(@pto_entry, as: @account_manager),
            params: { pto_entry: valid_params.merge(hours: new_hours, date: '') }

          assert_response :success
          assert_template :edit
          assert_includes assigns.keys, 'form'
        end

        test 'when params are VALID' do
          new_hours = @pto_entry.hours + 1

          put pto_entry_url(@pto_entry, as: @account_manager),
            params: { pto_entry: valid_params.merge(hours: new_hours) }

          assert_redirects_with_flash_success(pto_entries_url)
          assert_equal new_hours, @pto_entry.reload.hours
        end
      end
    end

    test 'for employee' do
      put pto_entry_url(@pto_entry, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete pto_entry_url(@pto_entry) }

    describe 'for account manager' do
      test 'when pto record does NOT belong to their account' do
        assert_no_difference 'PTOEntry.count' do
          delete pto_entry_url(@other_pto_entry, as: @account_manager)
        end
        assert_redirects_with_not_found_error
      end

      test 'when pto record belongs to their account' do
        assert_difference 'PTOEntry.count', -1 do
          delete pto_entry_url(@pto_entry, as: @account_manager)
        end
        assert_redirects_with_flash_success(pto_entries_url)
      end
    end

    test 'for employee' do
      delete pto_entry_url(@pto_entry, as: @employee)

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    attributes_for(:pto_entry)
  end
end
