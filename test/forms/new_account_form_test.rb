require 'test_helper'
require_relative './base_account_form_test'

class NewAccountFormTest < ActiveSupport::TestCase
  extend BaseAccountFormTest

  setup do
    @subject = NewAccountForm
  end

  test 'when nested forms are invalid' do
    office = attributes_for(:office, name: nil)
    user = attributes_for(:user, email: nil)
    plan = attributes_for(:plan, monthly_price: nil)
    attrs = attributes_for(:account, office: office, user: user, plan: plan)

    form = @subject.new(attrs)

    assert form.invalid?
    refute_empty form.errors.messages[:office_name]
    refute_empty form.errors.messages[:owner_email]
    refute_empty form.errors.messages[:plan_monthly_price]
  end
end
