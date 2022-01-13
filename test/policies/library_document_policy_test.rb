require 'test_helper'

class LibraryDocumentPolicyTest < PolicyTest
  describe '#show?' do
    test 'as super_admin' do
      user = users(:super_admin)
      record = library_documents(:oceanview_doc)

      assert_permit(:show, user, record)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = library_documents(:brookside_doc)

          refute_permit(:show, user, record)
        end

        test 'when record is canned' do
          user = users(role)
          record = library_documents(:canned)

          assert_permit(:show, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = library_documents(:oceanview_doc)

          assert_permit(:show, user, record)
        end
      end
    end

    test 'for employee when document not visible' do
      user = users(:employee)
      record = library_documents(:oceanview_invisible_doc)

      refute_permit(:show, user, record)
    end
  end

  describe '#update?' do
    test 'as super_admin' do
      user = users(:super_admin)
      record = library_documents(:oceanview_doc)

      assert_permit(:update, user, record)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = library_documents(:brookside_doc)

          refute_permit(:update, user, record)
        end

        test 'when record is canned' do
          user = users(role)
          record = library_documents(:canned)

          refute_permit(:update, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = library_documents(:oceanview_doc)

          assert_permit(:update, user, record)
        end
      end
    end

    test 'as employee' do
      user = users(:employee)
      record = library_documents(:oceanview_doc)

      refute_permit(:update, user, record)
    end
  end

  describe '#download?' do
    test 'as super_admin' do
      user = users(:super_admin)
      record = library_documents(:oceanview_doc)

      assert_permit(:download, user, record)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = library_documents(:brookside_doc)

          refute_permit(:download, user, record)
        end

        test 'when record is canned' do
          user = users(role)
          record = library_documents(:canned)

          assert_permit(:download, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = library_documents(:oceanview_doc)

          assert_permit(:download, user, record)
        end
      end
    end

    test 'for employee when document not visible' do
      user = users(:employee)
      record = library_documents(:oceanview_invisible_doc)

      refute_permit(:download, user, record)
    end
  end

  describe '#destroy?' do
    test 'as super_admin' do
      user = users(:super_admin)
      record = library_documents(:oceanview_doc)

      assert_permit(:destroy, user, record)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = library_documents(:brookside_doc)

          refute_permit(:destroy, user, record)
        end

        test 'when record is canned' do
          user = users(role)
          record = library_documents(:canned)

          refute_permit(:destroy, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = library_documents(:oceanview_doc)

          assert_permit(:destroy, user, record)
        end
      end
    end

    test 'as employee' do
      user = users(:employee)
      record = library_documents(:oceanview_doc)

      refute_permit(:destroy, user, record)
    end
  end

  describe '#permitted_attributes' do
    test 'as a super_admin' do
      user = users(:super_admin)
      library_document = build(:library_document)
      expected = [ :account_id, :name, :summary, :file, :is_visible_to_employees, :is_canned, :created_at, :type ]
      subject = LibraryDocumentPolicy.new(user, library_document)

      result = subject.permitted_attributes

      assert_equal expected.sort, result.sort
    end

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        user = users(role)
        library_document = build(:library_document)
        expected = [ :account_id, :name, :summary, :file, :is_visible_to_employees, :created_at, :type ]
        subject = LibraryDocumentPolicy.new(user, library_document)

        result = subject.permitted_attributes

        assert_equal expected.sort, result.sort
      end
    end

    test "as an employee" do
      user = users(:employee)
      library_document = build(:library_document)
      expected = [:name, :summary]
      subject = LibraryDocumentPolicy.new(user, library_document)

      result = subject.permitted_attributes

      assert_equal expected.sort, result.sort
    end
  end
end
