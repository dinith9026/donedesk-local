require 'test_helper'

class DocumentTypeFormTest < ActiveSupport::TestCase
  should validate_presence_of(:name)

  describe 'uniqueness validation' do
    test 'when creating' do
      account = accounts(:oceanview_dental)
      existing_type = account.document_types.first
      form = DocumentTypeForm.new(name: existing_type.name,
                                  account_id: account.id)

      assert form.invalid?
      assert_includes form.errors[:name], 'already taken'
    end

    test 'when updating' do
      account = accounts(:oceanview_dental)
      existing_type = account.document_types.first
      form = DocumentTypeForm.from_model(existing_type)

      assert form.valid?
    end
  end
end
