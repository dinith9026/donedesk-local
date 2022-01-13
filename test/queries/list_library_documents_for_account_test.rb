require 'test_helper'

class ListLibraryDocumentsForAccountTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:oceanview_dental)
    @subject = ListLibraryDocumentsForAccount.new(@account.id)
  end

  describe '#query' do
    test 'when document does NOT belong to account' do
      another_doc = library_documents(:brookside_doc)

      result = @subject.query

      refute_includes result, another_doc
    end

    test 'when document belongs to account' do
      doc = library_documents(:oceanview_doc)

      result = @subject.query

      assert_includes result, doc
    end

    test 'when document is canned' do
      canned = library_documents(:canned)

      result = @subject.query

      assert_includes result, canned
    end
  end
end
