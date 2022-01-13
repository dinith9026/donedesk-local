require 'test_helper'

class DocumentTypeTest < ActiveSupport::TestCase
  describe 'validations' do
    # See "Caveat" section for why we're defining a subject:
    # http://matchers.shoulda.io/docs/v3.1.1/Shoulda/Matchers/ActiveRecord.html#validate_uniqueness_of-instance_method
    subject { build(:document_type) }

    should validate_presence_of(:name)
    should allow_value('', ' ', nil).for(:account_id)
    should validate_uniqueness_of(:name)
      .scoped_to(:account_id)
      .case_insensitive
      .allow_blank
  end
end
