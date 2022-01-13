require 'test_helper'

class EmployeeDocumentPolicyTest < PolicyTest
  setup do
    ed_tx = employee_records(:ed)
    eric_oh = employee_records(:eric)
    mary_tx = employee_records(:mary)

    document_type = document_types(:oceanview_performance_review)
    confidential_document_type = document_types(:oceanview_confidential)

    @new_document_for_ed =
      EmployeeDocument.new(employee_record: ed_tx, document: build(:document, document_type: document_type))

    @new_confidential_document_for_ed =
      EmployeeDocument.new(employee_record: ed_tx, document: build(:document, document_type: confidential_document_type))

    @new_document_for_eric =
      EmployeeDocument.new(employee_record: eric_oh, document: build(:document, document_type: document_type))

    @new_confidential_document_for_eric =
      EmployeeDocument.new(employee_record: eric_oh, document: build(:document, document_type: confidential_document_type))

    @new_confidential_document_for_mary =
      EmployeeDocument.new(employee_record: mary_tx, document: build(:document, document_type: confidential_document_type))

    @document_for_ed = employee_documents(:oceanview_ed_w4)
    @confidential_document_for_ed = employee_documents(:oceanview_ed_confidential)
    @document_for_eric = employee_documents(:oceanview_eric_w4)
    @confidential_document_for_eric = employee_documents(:oceanview_eric_confidential)
    @document_for_mary = employee_documents(:oceanview_mary_w4)
    @confidential_document_for_mary = employee_documents(:oceanview_mary_confidential)
  end

  describe '#index?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        document = build(:document, document_type: document_types(:w4))
        employee_document = EmployeeDocument.new(employee_record: employee_records(:ed), document: document)

        assert_permit(:index, user, employee_document)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      document = build(:document, document_type: document_types(:w4))
      employee_document = EmployeeDocument.new(employee_record: employee_records(:ed), document: document)

      refute_permit(:index, user, employee_document)
    end
  end

  describe '#show?' do
    [:super_admin, :account_owner].each do |role|
      test "as an #{role}" do
        assert_permit(:show, users(role), employee_documents(:oceanview_ed_w4))
      end
    end

    describe 'as an account_manager' do
      test 'who is an office admin' do
        user = users(:account_manager)
        create(:offices_user, office: offices(:oceanview_tx), user: user)

        assert_permit(:show, user, employee_documents(:oceanview_ed_w4))
        assert_permit(:show, user, employee_documents(:oceanview_ed_confidential))
        refute_permit(:show, user, employee_documents(:oceanview_mary_confidential))
        refute_permit(:show, user, employee_documents(:brookside_ellen_w4))
      end

      test 'who is NOT an office admin' do
        user = users(:account_manager)

        assert_permit(:show, user, employee_documents(:oceanview_ed_w4))
        refute_permit(:show, user, employee_documents(:oceanview_ed_confidential))
        refute_permit(:show, user, employee_documents(:oceanview_mary_confidential))
        refute_permit(:show, user, employee_documents(:brookside_ellen_w4))
      end
    end

    test 'as an employee' do
      user = users(:employee)

      assert_permit(:show, user, employee_documents(:oceanview_ed_w4))
      refute_permit(:show, user, employee_documents(:oceanview_ed_confidential))
      refute_permit(:show, user, employee_documents(:oceanview_eric_w4))
    end
  end

  describe '#create?' do
    [:super_admin, :account_owner].each do |role|
      test "as a #{role}" do
        user = users(role)

        assert_permit(:create, user, @new_document_for_ed)
        assert_permit(:create, user, @new_confidential_document_for_ed)
        assert_permit(:create, user, @new_document_for_eric)
        assert_permit(:create, user, @new_confidential_document_for_eric)
      end
    end

    describe 'as an account_manager' do
      test 'who is an office admin' do
        user = users(:account_manager)
        create(:offices_user, office: offices(:oceanview_tx), user: user)

        assert_permit(:create, user, @new_document_for_ed)
        assert_permit(:create, user, @new_confidential_document_for_ed)
        assert_permit(:create, user, @new_document_for_eric)
        refute_permit(:create, user, @new_confidential_document_for_eric)
        refute_permit(:create, user, @new_confidential_document_for_mary)
      end

      test 'who is NOT an office admin' do
        user = users(:account_manager)

        assert_permit(:create, user, @new_document_for_ed)
        refute_permit(:create, user, @new_confidential_document_for_ed)
        refute_permit(:create, user, @new_confidential_document_for_mary)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      assert_permit(:create, user, @new_document_for_ed)
      refute_permit(:create, user, @new_confidential_document_for_ed)
      refute_permit(:create, user, @new_document_for_eric)
      refute_permit(:create, user, @new_confidential_document_for_eric)
    end
  end

  describe '#update?' do
    test 'as a super_admin' do
      user = users(:super_admin)

      assert_permit(:update, user, @document_for_ed)
      assert_permit(:update, user, @confidential_document_for_ed)
      assert_permit(:update, user, @document_for_eric)
      assert_permit(:update, user, @confidential_document_for_eric)
    end

    test 'as an account_owner' do
      user = users(:account_owner)

      assert_permit(:update, user, @document_for_ed)
      assert_permit(:update, user, @confidential_document_for_ed)
      assert_permit(:update, user, @document_for_eric)
      assert_permit(:update, user, @confidential_document_for_eric)
      refute_permit(:update, user, employee_documents(:brookside_ellen_w4))
    end

    describe 'as an account_manager' do
      test 'who is an office admin' do
        user = users(:account_manager)
        create(:offices_user, office: offices(:oceanview_tx), user: user)

        assert_permit(:update, user, @document_for_ed)
        assert_permit(:update, user, @confidential_document_for_ed)
        assert_permit(:update, user, @document_for_eric)
        refute_permit(:update, user, @confidential_document_for_eric)
        refute_permit(:update, user, @confidential_document_for_mary)
        refute_permit(:update, user, employee_documents(:brookside_ellen_w4))
      end

      test 'as an account_manager who is NOT an office admin' do
        user = users(:account_manager)

        assert_permit(:update, user, @document_for_ed)
        refute_permit(:update, user, @confidential_document_for_ed)
        assert_permit(:update, user, @document_for_eric)
        refute_permit(:update, user, @confidential_document_for_eric)
        refute_permit(:update, user, @confidential_document_for_mary)
        refute_permit(:update, user, employee_documents(:brookside_ellen_w4))
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:update, user, @document_for_ed)
      refute_permit(:update, user, @confidential_document_for_ed)
      refute_permit(:update, user, @document_for_eric)
      refute_permit(:update, user, @confidential_document_for_eric)
      refute_permit(:update, user, employee_documents(:brookside_ellen_w4))
    end
  end

  describe '#download?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        document = build(:document, document_type: document_types(:w4))
        employee_document = EmployeeDocument.new(employee_record: employee_records(:ed), document: document)

        assert_permit(:download, user, employee_document)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      document = build(:document, document_type: document_types(:w4))
      employee_document = EmployeeDocument.new(employee_record: employee_records(:ed), document: document)

      assert_permit(:download, user, employee_document)
    end
  end

  describe '#destroy?' do
    test 'as a super_admin' do
      user = users(:super_admin)

      assert_permit(:destroy, user, @document_for_ed)
      assert_permit(:destroy, user, @confidential_document_for_ed)
      assert_permit(:destroy, user, @document_for_eric)
      assert_permit(:destroy, user, @confidential_document_for_eric)
    end

    test 'as an account_owner' do
      user = users(:account_owner)

      assert_permit(:destroy, user, @document_for_ed)
      assert_permit(:destroy, user, @confidential_document_for_ed)
      assert_permit(:destroy, user, @document_for_eric)
      assert_permit(:destroy, user, @confidential_document_for_eric)
      refute_permit(:destroy, user, employee_documents(:brookside_ellen_w4))
    end


    describe 'as an account_manager' do
      test 'who is an office admin' do
        user = users(:account_manager)
        create(:offices_user, office: offices(:oceanview_tx), user: user)

        assert_permit(:destroy, user, @document_for_ed)
        assert_permit(:destroy, user, @confidential_document_for_ed)
        assert_permit(:destroy, user, @document_for_eric)
        refute_permit(:destroy, user, @confidential_document_for_eric)
        refute_permit(:destroy, user, @confidential_document_for_mary)
        refute_permit(:destroy, user, employee_documents(:brookside_ellen_w4))
      end

      test 'who is NOT an office admin' do
        user = users(:account_manager)

        assert_permit(:destroy, user, @document_for_ed)
        refute_permit(:destroy, user, @confidential_document_for_ed)
        assert_permit(:destroy, user, @document_for_eric)
        refute_permit(:destroy, user, @confidential_document_for_eric)
        refute_permit(:destroy, user, @confidential_document_for_mary)
        refute_permit(:destroy, user, employee_documents(:brookside_ellen_w4))
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:destroy, user, @document_for_ed)
      refute_permit(:destroy, user, @confidential_document_for_ed)
      refute_permit(:destroy, user, @document_for_eric)
      refute_permit(:destroy, user, @confidential_document_for_eric)
      refute_permit(:destroy, user, employee_documents(:brookside_ellen_w4))
    end
  end
end
