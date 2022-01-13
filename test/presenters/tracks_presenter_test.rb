require 'test_helper'

class TracksPresenterTest < ActiveSupport::TestCase
  test '#size' do
    track = Track.new

    subject = TracksPresenter.new([track], nil)

    assert_equal 1, subject.size
  end

  test '#active' do
    active = tracks(:for_oceanview)
    deactivated = tracks(:for_oceanview_deactivated)
    subject = TracksPresenter.new([active, deactivated], users(:account_manager))

    result = subject.active

    assert_includes result.map(&:id), active.id, 'Active track should be included'
    refute_includes result.map(&:id), deactivated.id, 'Deactivated track should NOT be included'
  end

  test '#deactivated' do
    active = tracks(:for_oceanview)
    deactivated = tracks(:for_oceanview_deactivated)
    subject = TracksPresenter.new([active, deactivated], users(:account_manager))

    result = subject.deactivated

    refute_includes result.map(&:id), active.id, 'Active track should NOT be included'
    assert_includes result.map(&:id), deactivated.id, 'Deactivated track should be included'
  end

  test 'paths' do
    track = Track.new(id: 1)

    subject = TracksPresenter.new([track], nil)

    refute_nil subject.new_path
  end
end
