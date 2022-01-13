require 'test_helper'

class LibraryDocumentsPresenterTest < ActiveSupport::TestCase
  setup do
    user = users(:account_owner)
    @canned = library_documents(:canned)
    @custom = library_documents(:oceanview_doc)
    @subject = LibraryDocumentsPresenter.new([@canned, @custom], user)
  end

  test "custom" do
    result = @subject.custom.map { |p| p.id }

    assert_includes result, @custom.id
    refute_includes result, @canned.id
  end

  test "canned" do
    result = @subject.canned.map { |p| p.id }

    refute_includes result, @custom.id
    assert_includes result, @canned.id
  end
end
