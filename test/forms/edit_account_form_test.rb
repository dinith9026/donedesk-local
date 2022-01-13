require 'test_helper'
require_relative './base_account_form_test'

class EditAccountFormTest < ActiveSupport::TestCase
  extend BaseAccountFormTest

  setup do
    @subject = EditAccountForm
  end
end
