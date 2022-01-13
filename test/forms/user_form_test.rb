require 'test_helper'

class UserFormTest < ActiveSupport::TestCase
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should_not allow_value('invalid').for(:email)
  should_not allow_value('invalid@x').for(:email)
  should_not allow_value('invalid@x.').for(:email)
  should allow_value('valid@x.x').for(:email)
  should allow_value('valid++test@example.com').for(:email)
  should_not allow_value('super_admin').for(:role)
  should_not allow_value('account_owner').for(:role)
  should allow_value('employee').for(:role)
  should allow_value('account_manager').for(:role)

  describe 'uniqueness validation' do
    test 'when creating' do
      existing_user = users(:employee)
      form = UserForm.new(email: " #{existing_user.email}")

      form.valid?

      assert_includes form.errors[:email], 'already taken'
    end

    test 'when updating' do
      existing_user = users(:employee)
      form = UserForm.from_model(existing_user)

      assert form.valid?
    end
  end
end
