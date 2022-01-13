require 'test_helper'

class EmployeeDocumentPresenterTest < ActiveSupport::TestCase
  subject { EmployeeDocumentPresenter.new(build(:employee_document), nil) }
  should delegate_method(:summary).to(:employee_document)
  should delegate_method(:file_name).to(:employee_document)
  should delegate_method(:employee_record_full_name).to(:employee_document)
  should delegate_method(:document).to(:employee_document)

  test 'paths' do
    subject = EmployeeDocumentPresenter.new(employee_documents(:oceanview_ed_w4), nil)

    refute_nil subject.download_path
  end
end
