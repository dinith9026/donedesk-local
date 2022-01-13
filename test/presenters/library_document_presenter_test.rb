require 'test_helper'

class LibraryDocumentPresenterTest < ActiveSupport::TestCase
  subject { LibraryDocumentPresenter.new(nil, nil) }
  should delegate_method(:name).to(:library_document)
  should delegate_method(:file_name).to(:library_document)
  should delegate_method(:summary).to(:library_document)
  should delegate_method(:is_canned?).to(:library_document)
  should delegate_method(:is_custom?).to(:library_document)

  describe '#when_existing_record' do
    test 'when true' do
      record = library_documents(:oceanview_doc)
      subject = LibraryDocumentPresenter.new(record, nil)
      block_called = false

      subject.when_existing_record do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when false' do
      record = LibraryDocument.new
      subject = LibraryDocumentPresenter.new(record, nil)
      block_called = false

      subject.when_existing_record do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#type' do
    test 'when custom' do
      doc = library_documents(:oceanview_doc)

      subject = LibraryDocumentPresenter.new(doc, nil)

      assert_equal 'My Documents', subject.type
    end

    test 'when canned' do
      doc = library_documents(:canned)

      subject = LibraryDocumentPresenter.new(doc, nil)

      assert_equal 'Other Documents', subject.type
    end
  end

  test '#created_at' do
    library_document = build(:library_document, created_at: 2.days.ago)
    subject = LibraryDocumentPresenter.new(library_document, nil)
    expected = library_document.created_at.strftime('%Y-%m-%d')

    result = subject.created_at

    assert_equal expected, result
  end

  test 'paths and urls' do
    library_document = build(:library_document, id: SecureRandom.uuid)
    subject = LibraryDocumentPresenter.new(library_document, nil)

    refute_nil subject.show_path
    refute_nil subject.edit_path
    refute_nil subject.download_path
    refute_nil subject.destroy_path
  end
end
