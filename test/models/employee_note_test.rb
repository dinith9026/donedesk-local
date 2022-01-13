require 'test_helper'
require_relative '../models/concerns/common_employee_note_validation_tests'

class EmployeeNoteTest < ActiveSupport::TestCase
  include CommonEmployeeNoteValidationTests

  should delegate_method(:full_name).to(:creator).with_prefix
end
