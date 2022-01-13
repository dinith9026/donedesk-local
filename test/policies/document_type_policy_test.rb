require 'test_helper'

class DocumentTypePolicyTest < PolicyTest
  describe '#update?' do
    setup do
      @canned = document_types(:w4)
      @custom = document_types(:oceanview_performance_review)
      @other_custom = document_types(:brookside_performance_review)
    end

    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:update, user, @canned)
      assert_permit(:update, user, @custom)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:update, user, @canned)
        refute_permit(:update, user, @other_custom)
        assert_permit(:update, user, @custom)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:update, user, @canned)
      refute_permit(:update, user, @other_custom)
      refute_permit(:update, user, @custom)
    end
  end

  describe '#destroy?' do
    setup do
      @canned_with_documents = document_types(:w4)
      @canned_without_documents = create(:document_type)
      @custom_with_documents = document_types(:oceanview_performance_review)
      @custom_without_documents = create(:document_type, account: accounts(:oceanview_dental))
      @other_custom_without_documents = create(:document_type, account: accounts(:brookside_dental))
    end

    test 'as a super admin' do
      user = users(:super_admin)

      refute_permit(:destroy, user, @canned_with_documents)
      assert_permit(:destroy, user, @canned_without_documents)
      refute_permit(:destroy, user, @custom_with_documents)
      assert_permit(:destroy, user, @custom_without_documents)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:destroy, user, @canned_with_documents)
        refute_permit(:destroy, user, @canned_without_documents)
        refute_permit(:destroy, user, @custom_with_documents)
        assert_permit(:destroy, user, @custom_without_documents)
        refute_permit(:destroy, user, @other_custom_without_documents)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:destroy, user, @canned_with_documents)
      refute_permit(:destroy, user, @canned_without_documents)
      refute_permit(:destroy, user, @custom_with_documents)
      refute_permit(:destroy, user, @custom_without_documents)
      refute_permit(:destroy, user, @other_custom_without_documents)
    end
  end

  describe '#permitted_attributes' do
    test 'for super_admin' do
      user = users(:super_admin)
      document_type = DocumentType.new

      subject = DocumentTypePolicy.new(user, document_type)

      assert_equal [:name, :applies_to, :is_canned, :is_confidential], subject.permitted_attributes
    end

    test 'for account_owner' do
      user = users(:account_owner)
      document_type = DocumentType.new

      subject = DocumentTypePolicy.new(user, document_type)

      assert_equal [:name, :applies_to, :is_confidential], subject.permitted_attributes
    end

    test 'for account_manager' do
      user = users(:account_manager)
      document_type = DocumentType.new

      subject = DocumentTypePolicy.new(user, document_type)

      assert_equal [:name, :applies_to], subject.permitted_attributes
    end

    test 'for employee' do
      user = users(:employee)
      document_type = DocumentType.new

      subject = DocumentTypePolicy.new(user, document_type)

      assert_equal [], subject.permitted_attributes
    end
  end
end
