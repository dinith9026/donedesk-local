require 'test_helper'

class OfficePolicyTest < PolicyTest
  setup do
    @document_group = create_office_document_group_for(accounts(:oceanview_dental))
  end

  describe '#show?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:show, user, Office)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        office = offices(:oceanview_tx)
        other_office = offices(:brookside)

        assert_permit(:show, user, office)
        refute_permit(:show, user, other_office)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:show, user, Office)
    end
  end

  describe '#update?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:edit, user, Office)
      assert_permit(:update, user, Office)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        office = offices(:oceanview_tx)
        other_office = offices(:brookside)

        assert_permit(:edit, user, office)
        assert_permit(:update, user, office)
        refute_permit(:edit, user, other_office)
        refute_permit(:update, user, other_office)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:edit, user, Office)
      refute_permit(:update, user, Office)
    end
  end

  describe '#assign_admin?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:assign_admin, user, Office)
    end

    test 'as a account_owner' do
      user = users(:account_owner)
      office = offices(:oceanview_tx)
      other_office = offices(:brookside)

      assert_permit(:assign_admin, user, office)
      refute_permit(:assign_admin, user, other_office)
    end

    [:account_manager, :employee].each do |role|
      test "as a #{role}" do
        user = users(role)

        refute_permit(:assign_admin, user, Office)
      end
    end
  end

  describe '#remove_admin?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:remove_admin, user, Office)
    end

    test 'as a account_owner' do
      user = users(:account_owner)
      office = offices(:oceanview_tx)
      other_office = offices(:brookside)

      assert_permit(:remove_admin, user, office)
      refute_permit(:remove_admin, user, other_office)
    end

    [:account_manager, :employee].each do |role|
      test "as a #{role}" do
        user = users(role)

        refute_permit(:remove_admin, user, Office)
      end
    end
  end

  describe '#new_document?' do
    test 'as a super_admin' do
      assert_permit(:new_document, users(:super_admin), offices(:oceanview_tx))
      assert_permit(:new_document, users(:super_admin), offices(:brookside))
    end

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        user = users(role)
        office = offices(:oceanview_tx)
        other_office = offices(:brookside)

        assert_permit(:new_document, user, office)
        refute_permit(:new_document, user, other_office)
      end
    end

    test 'as an employee' do
      refute_permit(:new_document, users(:employee), offices(:oceanview_tx))
    end
  end

  describe '#destroy?' do
    test 'as a super admin' do
      user = users(:super_admin)
      office_with_employee_records = offices(:oceanview_tx)
      office_without_employee_records = create(:office, document_group: @document_group)

      refute_permit(:destroy, user, office_with_employee_records)
      assert_permit(:destroy, user, office_without_employee_records)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        office_with_employee_records = offices(:oceanview_tx)
        office_without_employee_records = create(:office, account: user.account, document_group: @document_group)
        other_office = offices(:brookside)

        refute_permit(:destroy, user, other_office)
        refute_permit(:destroy, user, office_with_employee_records)
        assert_permit(:destroy, user, office_without_employee_records)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      office_without_employee_records = create(:office, account: user.account, document_group: @document_group)

      refute_permit(:destroy, user, office_without_employee_records)
    end
  end

  describe '#permitted_attributes' do
    test 'when account does NOT have time tracking enabled' do
      user = User.new
      office = Office.new
      office.stubs(:account_time_tracking).returns(false)

      subject = OfficePolicy.new(user, office)

      refute_includes subject.permitted_attributes, :tracks_time
    end

    test 'when account has time tracking enabled' do
      user = User.new
      office = Office.new
      office.stubs(:account_time_tracking).returns(true)

      subject = OfficePolicy.new(user, office)

      assert_includes subject.permitted_attributes, :tracks_time
    end
  end
end
