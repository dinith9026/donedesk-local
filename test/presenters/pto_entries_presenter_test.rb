require 'test_helper'

class PTOEntriesPresenterTest < ActiveSupport::TestCase
  describe '#active_employee_records' do
    test 'without needed context' do
      subject = PTOEntriesPresenter.new([], nil)

      assert_raise NoMethodError do
        subject.active_employee_records
      end
    end

    test 'with needed context' do
      account_mock = Minitest::Mock.new
      account_mock.expect(:active_employee_records, 1)
      subject =
        PTOEntriesPresenter
        .new([], nil)
        .with_context(current_account: account_mock)

      subject.active_employee_records

      assert_mock account_mock
    end
  end

  describe '#date_from' do
    test 'without needed context' do
      subject = PTOEntriesPresenter.new([], nil)

      assert_raise NoMethodError do
        subject.date_from
      end
    end

    test 'with needed context' do
      date_range = '2018-01-01'.to_date..'2018-01-02'.to_date
      subject = PTOEntriesPresenter.new([], nil).with_context(date_range: date_range)

      assert_equal 'Mon, Jan 1, 2018', subject.date_from
    end

    test 'with custom format' do
      date_range = '2018-01-01'.to_date..'2018-01-02'.to_date
      subject = PTOEntriesPresenter.new([], nil).with_context(date_range: date_range)

      assert_equal '01/01/2018', subject.date_from('%m/%d/%Y')
    end
  end

  describe '#date_to' do
    test 'without needed context' do
      subject = PTOEntriesPresenter.new([], nil)

      assert_raise NoMethodError do
        subject.date_to
      end
    end

    test 'with needed context' do
      date_range = '2018-01-01'.to_date..'2018-01-31'.to_date
      subject = PTOEntriesPresenter.new([], nil).with_context(date_range: date_range)

      assert_equal 'Wed, Jan 31, 2018', subject.date_to
    end

    test 'with custom format' do
      date_range = '2018-01-01'.to_date..'2018-01-31'.to_date
      subject = PTOEntriesPresenter.new([], nil).with_context(date_range: date_range)

      assert_equal '01/31/2018', subject.date_to('%m/%d/%Y')
    end
  end
end
