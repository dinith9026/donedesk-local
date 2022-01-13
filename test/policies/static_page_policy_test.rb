require 'test_helper'

class StaticPagePolicyTest < PolicyTest
  describe 'serices pages' do
    [:insurance, :payroll, :background_check].each do |page|
      [:super_admin, :account_owner, :account_manager].each do |role|
        test "#{page} for #{role}" do
          user = users(role)
          record = nil

          assert_permit(page, user, record)
        end
      end

      test 'for employee' do
        user = users(:employee)
        record = nil

        refute_permit(page, user, record)
      end
    end
  end

  describe "coaching pages" do
    [:compliance_coaching, :hr_coaching, :health_insurance_coaching].each do |page|
      [:super_admin, :account_owner, :account_manager].each do |role|
        test "#{page} for #{role}" do
          user = users(role)
          record = nil

          assert_permit(page, user, record)
        end
      end

      test "#{page} for employee" do
        user = users(:employee)
        record = nil

        refute_permit(page, user, record)
      end
    end
  end

  describe '#terms?' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        user = users(role)
        record = nil

        assert_permit(:terms, user, record)
      end
    end
  end

  describe '#privacy_policy?' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        user = users(role)
        record = nil

        assert_permit(:privacy_policy, user, record)
      end
    end
  end

  describe '#logout_or_continue?' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        user = users(role)
        record = nil

        assert_permit(:logout_or_continue, user, record)
      end
    end
  end
end
