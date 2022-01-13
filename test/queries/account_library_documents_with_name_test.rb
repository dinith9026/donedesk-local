require 'test_helper'

class AccountLibraryDocumentsWithNameTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:oceanview_dental)
  end

  describe '#query' do
    test 'when document does NOT belong to account' do
      another_doc = library_documents(:brookside_doc)
      subject = AccountLibraryDocumentsWithName.new(another_doc.name, @account.id)

      result = subject.query

      refute_includes result, another_doc
    end

    describe 'when document belongs to account' do
      test 'and name is already taken' do
        doc = library_documents(:oceanview_doc)
        subject = AccountLibraryDocumentsWithName.new(doc.name, @account.id)

        result = subject.query

        assert_includes result, doc
      end

      test 'and name is NOT already taken' do
        name = SecureRandom.hex
        subject = AccountLibraryDocumentsWithName.new(name, @account.id)

        result = subject.query

        assert_equal 0, result.count
      end
    end

    test 'when document is canned' do
      canned = library_documents(:canned)
      subject = AccountLibraryDocumentsWithName.new(canned.name, @account.id)

      result = subject.query

      refute_includes result, canned
    end
  end
end
