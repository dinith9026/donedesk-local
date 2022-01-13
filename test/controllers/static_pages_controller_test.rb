require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  [
    :insurance,
    :payroll,
    :background_check,
    :compliance_coaching,
    :hr_coaching,
    :health_insurance_coaching,
    :terms,
    :privacy_policy,
    :logout_or_continue
  ].each do | page|
    test "##{page}" do
      get send("#{page}_page_path", as: users(:account_owner))

      assert_response :success
    end
  end
end
