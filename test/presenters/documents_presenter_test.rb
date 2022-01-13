require 'test_helper'

class DocumentsPresenterTest < ActiveSupport::TestCase
  test '#employees' do
    account = accounts(:oceanview_dental)
    document = documents(:oceanview_ed_w4)
    subject = DocumentsPresenter.new([document], nil)

    result = subject.employees(account)

    refute_nil result
  end
end
