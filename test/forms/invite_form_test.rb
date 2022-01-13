require 'test_helper'

class InviteFormTest < ActiveSupport::TestCase
  should validate_presence_of(:email)
  should_not allow_value('invalid').for(:email)
  should allow_value('invalid@x').for(:email)
  should allow_value('invalid@x.').for(:email)
  should allow_value('valid++test@example.com').for(:email)

  test 'when email already exists' do
    existing_user = users(:employee)
    form = InviteForm.new(email: " #{existing_user.email} ")

    form.valid?

    assert_includes form.errors[:email], 'already exists'
  end
end
