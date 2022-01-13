require 'test_helper'

class OfficesPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test 'initialize' do
    offices = [offices(:oceanview_tx), offices(:oceanview_oh)]
    user = users(:account_manager)

    result = OfficesPresenter.new(offices, user)

    assert_equal 2, result.count
    assert_respond_to result, :each
  end

  test 'paths' do
    office = Office.new(id: 1)

    subject = OfficesPresenter.new(office, nil)

    refute_nil subject.new_path
  end
end
