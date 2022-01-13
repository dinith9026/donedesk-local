require 'test_helper'

class OfficePresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  subject { OfficePresenter.new(nil, nil) }
  should delegate_method(:name).to(:office)
  should delegate_method(:phone).to(:office)
  should delegate_method(:street_address).to(:office)
  should delegate_method(:address2).to(:office)
  should delegate_method(:city).to(:office)
  should delegate_method(:state).to(:office)
  should delegate_method(:zip).to(:office)
  should delegate_method(:time_zone).to(:office)
  should delegate_method(:document_compliance_percentage).to(:office)
  should delegate_method(:training_compliance_percentage).to(:office)

  test '#initialize' do
    office = offices(:oceanview_tx)

    result = OfficePresenter.new(office, nil)

    assert_equal office.id, result.id
  end

  describe '#when_time_tracking_enabled_for_account' do
    test 'when true' do
      office = Office.new
      office.stubs(:account_time_tracking).returns(true)
      subject = OfficePresenter.new(office, nil)
      block_called = false

      subject.when_time_tracking_enabled_for_account { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      office = Office.new
      office.stubs(:account_time_tracking).returns(false)
      subject = OfficePresenter.new(office, nil)
      block_called = false

      subject.when_time_tracking_enabled_for_account { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#tracks_time?' do
    test 'when true' do
      office = Office.new(tracks_time: true)

      subject = OfficePresenter.new(office, nil)

      assert_equal 'Yes', subject.tracks_time?
    end

    test 'when false' do
      office = Office.new(tracks_time: false)

      subject = OfficePresenter.new(office, nil)

      assert_equal 'No', subject.tracks_time?
    end
  end

  test '#employed_employees_count' do
    office = offices(:oceanview_tx)

    subject = OfficePresenter.new(office, nil)

    office.stub(:employed_employees, [1, 2]) do
      assert_equal 2, subject.employed_employees_count
    end
  end

  test 'paths' do
    office = offices(:oceanview_tx)

    subject = OfficePresenter.new(office, nil)

    refute_nil subject.show_path
    refute_nil subject.edit_path
  end
end
