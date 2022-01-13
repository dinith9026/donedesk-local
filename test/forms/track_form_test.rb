require 'test_helper'

class TrackFormTest < ActiveSupport::TestCase
  describe 'validate' do
    test 'when all params are blank' do
      form = TrackForm.new

      refute form.valid?
      assert_includes form.errors[:name], "can't be blank"
      assert_includes form.errors[:base], "A track must have at least 1 course"
    end
  end
end
