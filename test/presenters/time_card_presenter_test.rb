require 'test_helper'

class TimeCardPresenterTest < ActiveSupport::TestCase
  describe '#icon_class' do
    test 'when not clocked in' do
      time_card = build_time_card
      time_card.stubs(:clocked_in?).returns(false)

      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '', subject.icon_class
    end

    test 'when clocked in' do
      time_card = build_time_card
      time_card.stubs(:clocked_in?).returns(true)

      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal 'black', subject.icon_class
    end
  end

  describe '#when_has_entries' do
    test 'when true' do
      time_card = build_time_card
      time_card.stubs(:time_entries).returns([TimeEntry.new])
      subject = TimeCardPresenter.new(time_card, policy_stub)
      block_called = false

      subject.when_has_entries { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      time_card = build_time_card
      time_card.stubs(:time_entries).returns([])
      subject = TimeCardPresenter.new(time_card, policy_stub)
      block_called = false

      subject.when_has_entries { block_called = true }

      assert_equal false, block_called
    end
  end

  test '#last_entry_time_and_type' do
    ed = employee_records(:ed)
    first_entry = clock_in(ed, '9:00 AM')
    last_entry = clock_out(ed, '5:00 PM')
    time_card = build_time_card
    time_card.stubs(:time_entries).returns([first_entry, last_entry])
    subject = TimeCardPresenter.new(time_card, policy_stub)

    assert_equal '05:00 PM - Clock out', subject.last_entry_time_and_type
  end

  describe '#when_missing_entries' do
    test 'when true' do
      time_card = build_time_card
      time_card.stubs(:has_missing_entries?).returns(true)
      subject = TimeCardPresenter.new(time_card, policy_stub)
      block_called = false

      subject.when_missing_entries { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      time_card = build_time_card
      time_card.stubs(:has_missing_entries?).returns(false)
      subject = TimeCardPresenter.new(time_card, policy_stub)
      block_called = false

      subject.when_missing_entries { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#when_not_missing_entries' do
    test 'when true' do
      time_card = build_time_card
      time_card.stubs(:has_missing_entries?).returns(false)
      subject = TimeCardPresenter.new(time_card, policy_stub)
      block_called = false

      subject.when_not_missing_entries { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      time_card = build_time_card
      time_card.stubs(:has_missing_entries?).returns(false)
      subject = TimeCardPresenter.new(time_card, policy_stub)
      block_called = false

      subject.when_not_missing_entries { block_called = true }

      assert_equal true, block_called
    end
  end

  describe '#regular_time' do
    test 'when precision is NOT significant' do
      time_card = build_time_card
      time_card.stubs(:regular_time).returns(8.0)
      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '8', subject.regular_time
    end

    test 'when precision is significant' do
      time_card = build_time_card
      time_card.stubs(:regular_time).returns(8.1)
      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '8.1', subject.regular_time
    end
  end

  describe '#break_time' do
    test 'when precision is NOT significant' do
      time_card = build_time_card
      time_card.stubs(:break_time).returns(8.0)
      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '8', subject.break_time
    end

    test 'when precision is significant' do
      time_card = build_time_card
      time_card.stubs(:break_time).returns(8.1)
      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '8.1', subject.break_time
    end
  end

  describe '#pto_time' do
    test 'when precision is NOT significant' do
      time_card = build_time_card
      time_card.stubs(:pto_time).returns(8.0)
      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '8', subject.pto_time
    end

    test 'when precision is significant' do
      time_card = build_time_card
      time_card.stubs(:pto_time).returns(8.1)
      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal '8.1', subject.pto_time
    end
  end

  describe '#disable_button_for' do
    test 'when entry type is not permitted' do
      time_card = build_time_card
      time_card.stubs(:permitted_to?).returns(false)

      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal true, subject.disable_button_for?('foo')
    end

    test 'when entry type is permitted' do
      time_card = build_time_card
      time_card.stubs(:permitted_to?).returns(true)

      subject = TimeCardPresenter.new(time_card, policy_stub)

      assert_equal false, subject.disable_button_for?('foo')
    end
  end

  test '#entry_types' do
    time_card = build_time_card
    subject = TimeCardPresenter.new(time_card, policy_stub)

    assert_equal TimeEntry.entry_types.keys, subject.entry_types
  end

  test '#time_entries' do
    time_card = build_time_card
    time_card.stubs(:time_entries).returns([build(:time_entry)])
    subject = TimeCardPresenter.new(time_card, policy_stub)

    result = subject.time_entries

    assert_equal 1, result.count
    assert_kind_of TimeEntryPresenter, result.first
  end

  test '#modal_title' do
    time_card = build_time_card
    subject = TimeCardPresenter.new(time_card, policy_stub)

    travel_to Time.new(2018, 07, 17) do
      assert_equal 'Tuesday - Jul 17, 2018', subject.modal_title
    end
  end

  test '#date' do
    time_card = build_time_card(date: '2018-01-01'.to_date)
    subject = TimeCardPresenter.new(time_card, policy_stub)

    assert_equal 'Mon, Jan 1, 2018', subject.date
  end

  test '#time_entries_path' do
    time_card = build_time_card(date: '2018-01-01'.to_date)
    subject = TimeCardPresenter.new(time_card, policy_stub)
    id = time_card.employee_record.id
    expected_path = "/employee_records/#{id}/time_entries?date=2018-01-01"

    assert_equal expected_path, subject.time_entries_path
  end
end
