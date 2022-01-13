module CommonTimeEntryValidationTests
  extend ActiveSupport::Concern

  included do
    should validate_presence_of(:entry_type)
    should validate_presence_of(:occurred_at)

    test 'when entry type is not allowed' do
      assert_equal false, @subject.valid?
    end
  end
end
