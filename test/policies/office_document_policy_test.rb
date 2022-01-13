require 'test_helper'

class OfficeDocumentPolicyTest < PolicyTest
  [:show, :new, :create, :edit, :update, :download, :view_history, :destroy].each do |action|
    describe "##{action}?" do
      test 'for super_admin' do
        user = users(:super_admin)
        office_document = office_documents(:oceanview_tx_maintenance_checklist)

        assert_permit(:view_history, user, office_document)
      end

      describe 'for account_owner' do
        test 'when document does not belong to account' do
          user = users(:account_owner)
          office_document = office_documents(:brookside_maintenance_checklist)

          refute_permit(:view_history, user, office_document)
        end

        test 'when document belongs to account' do
          user = users(:account_owner)
          office_document = office_documents(:oceanview_tx_maintenance_checklist)

          assert_permit(:view_history, user, office_document)
        end
      end

      describe 'for account_manager' do
        test 'when document does not belong to account' do
          user = users(:account_manager)
          office_document = office_documents(:brookside_maintenance_checklist)

          refute_permit(:view_history, user, office_document)
        end

        test 'when document belongs to account and is NOT confidential' do
          user = users(:account_manager)
          office_document = office_documents(:oceanview_tx_maintenance_checklist)

          assert_permit(:view_history, user, office_document)
        end

        test 'when document belongs to account and is confidential and user is NOT office admin' do
          user = users(:account_manager)
          office_document = office_documents(:oceanview_tx_maintenance_checklist)
          office_document.stubs(:is_confidential).returns(true)
          office_document.stubs(:office_is_admin?).returns(false)

          refute_permit(:view_history, user, office_document)
        end

        test 'when document belongs to account and is confidential and user is office admin' do
          user = users(:account_manager)
          office_document = office_documents(:oceanview_tx_maintenance_checklist)
          office_document.stubs(:is_confidential).returns(true)
          office_document.stubs(:office_is_admin?).returns(true)

          assert_permit(:view_history, user, office_document)
        end
      end

      test 'for employee' do
        user = users(:employee)
        office_document = office_documents(:oceanview_tx_maintenance_checklist)

        refute_permit(:view_history, user, office_document)
      end
    end
  end
end
