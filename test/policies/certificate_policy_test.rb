require 'test_helper'

class CertificatePolicyTest < PolicyTest
  describe '#show?' do
    test 'as a super_admin' do
      assert_permit(:show, users(:super_admin), build(:certificate))
    end

    [:account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when certificate does NOT belong to account' do
          refute_permit(:show, users(role), certificates(:for_brookside_ellen))
        end

        test 'when certificate belongs to account' do
          assert_permit(:show, users(role), certificates(:for_oceanview_ed))
        end
      end
    end

    describe 'as an employee' do
      test 'when certificate does NOT belong to user' do
        refute_permit(:show, users(:employee), certificates(:for_oceanview_eric))
      end

      test 'when certificate belongs to user' do
        assert_permit(:show, users(:employee), certificates(:for_oceanview_ed))
      end
    end
  end
end
