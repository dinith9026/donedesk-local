require 'test_helper'

class DocumentPolicyTest < PolicyTest
  describe '#index?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        assert_permit(:index, users(role), Document.new)
      end
    end

    test 'as an employee' do
      refute_permit(:index, users(:employee), Document.new)
    end
  end
end
