require 'test_helper'
require_relative '../models/concerns/common_office_validation_tests'

class OfficeFormTest < ActiveSupport::TestCase
  setup do
    @subject = Office
  end

  include CommonOfficeValidationTests
end
