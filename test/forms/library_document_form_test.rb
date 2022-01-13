require 'test_helper'

class LibraryDocumentFormTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should validate_presence_of(:name)
  should validate_presence_of(:file)

  test '#initialize' do
    account_id = SecureRandom.uuid
    name = 'Name'
    file = fixture_file_upload('test.pdf')

    form = LibraryDocumentForm.new(account_id: account_id, name: name, file: file)

    assert_equal account_id, form.account_id
    assert_equal name, form.name
    assert_equal file, form.file
    assert_equal false, form.is_canned
  end

  test 'when title is already taken for the account' do
    existing_doc = library_documents(:oceanview_doc)

    form = LibraryDocumentForm.new(
      name: existing_doc.name,
      account_id: existing_doc.account_id)

    assert form.invalid?
    assert_includes form.errors[:name], 'already taken'
  end

  test 'when size of file exceeds max allowed size' do
    params = valid_params.merge(file: valid_file)

    form = LibraryDocumentForm.from_params(params)

    File.stub(:size, LibraryDocument::MAX_DOCUMENT_SIZE_IN_BYTES + 1) do
      assert form.invalid?
    end
    assert_includes form.errors[:file], 'too large'
  end

  test 'when content type of file is invalid' do
    params = valid_params.merge(file: invalid_file)

    form = LibraryDocumentForm.from_params(params)

    assert form.invalid?
    assert_includes form.errors[:file], 'type not allowed'
  end

  private

  def valid_params
    attributes_for(:library_document)
  end

  def valid_file
    fixture_file_upload('test.pdf', 'application/pdf')
  end

  def invalid_file
    fixture_file_upload('test.pdf', 'not/valid')
  end
end
