require 'test_helper'

class CertificatesPresenterTest < ActiveSupport::TestCase
  test 'initialize' do
    certificates = [certificates(:for_oceanview_ed), certificates(:for_oceanview_eric)]
    user = users(:account_manager)

    result = CertificatesPresenter.new(certificates, user)

    assert_equal 2, result.count
    assert_respond_to result, :each
  end
end
