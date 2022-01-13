require 'test_helper'

class DocumentTypePresenterTest < ActiveSupport::TestCase
  subject { DocumentTypePresenter.new(nil, nil) }
  should delegate_method(:id).to(:document_type)
  should delegate_method(:name).to(:document_type)
end
