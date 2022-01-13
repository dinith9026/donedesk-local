require 'test_helper'

class EmployeeNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee_record = employee_records(:ed)
    @other_employee_record = employee_records(:ellen)
  end

  describe '#new' do
    it_requires_authenticated_user do
      get new_employee_record_employee_note_url(employee_record_id: @employee_record.id)
    end

    describe "for account_owner" do
      test 'when employee record does NOT belong to their account' do
        user = users(:account_owner)

        get new_employee_record_employee_note_url(@other_employee_record, as: user)

        assert_redirects_with_not_found_error
      end

      test 'when employee record belongs to their account' do
        user = users(:account_owner)

        get new_employee_record_employee_note_url(@employee_record, as: user)

        assert_response :success
        refute_nil assigns[:form]
        refute_nil assigns[:form].employee_record
        refute_nil assigns[:form].current_account
      end
    end

    describe "for account_manager" do
      test 'when employee record does NOT belong to their account' do
        user = users(:account_manager)

        get new_employee_record_employee_note_url(@other_employee_record, as: user)

        assert_redirects_with_not_found_error
      end

      test 'when employee record belongs to their account and is their own' do
        user = users(:account_manager)

        get new_employee_record_employee_note_url(user.employee_record, as: user)

        assert_redirects_with_not_authorized_error
      end

      test 'when employee record belongs to their account and is not their own' do
        user = users(:account_manager)

        get new_employee_record_employee_note_url(@employee_record, as: user)

        assert_response :success
        refute_nil assigns[:form]
        refute_nil assigns[:form].employee_record
        refute_nil assigns[:form].current_account
      end
    end

    test 'for employee' do
      get new_employee_record_employee_note_url(@employee_record, as: @employee_record.user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user do
      post employee_record_employee_notes_url(employee_record_id: @employee_record.id)
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when employee record does NOT belong to their account' do
          user = users(role)

          assert_no_difference 'EmployeeNote.count' do
            post employee_record_employee_notes_url(@other_employee_record, as: user),
              params: { employee_note: valid_params }
          end
          assert_redirects_with_not_found_error
        end

        describe 'when employee record belongs to their account' do
          test 'when params are invalid' do
            user = users(role)

            assert_no_difference 'EmployeeNote.count' do
              post employee_record_employee_notes_url(@employee_record, as: user),
                params: { employee_note: { body: nil } }
            end
            assert_template :new
            refute_nil assigns[:form]
            refute_nil assigns[:form].employee_record
            refute_nil assigns[:form].current_account
          end

          test 'when params are valid' do
            user = users(role)

            assert_difference 'EmployeeNote.count', 1 do
              post employee_record_employee_notes_url(@employee_record, as: user),
                params: { employee_note: valid_params }
            end
            assert_redirects_with_flash_success(root_path)
          end
        end
      end
    end

    test 'for employee' do
      assert_no_difference 'EmployeeNote.count' do
        post employee_record_employee_notes_url(@employee_record, as: @employee_record.user),
          params: { employee_note: valid_params }
      end
      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    attributes_for(:employee_note)
  end

end
