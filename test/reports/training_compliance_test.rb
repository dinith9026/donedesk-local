require 'test_helper'

class TrainingComplianceTest < ActiveSupport::TestCase
  describe '#percentage' do
    test 'when employee array contains nil' do
      subject = TrainingCompliance.new([nil])

      assert_equal 0, subject.percentage
    end

    test 'when no assignments have been completed' do
      employee_record = build(:employee_record)
      employee_record.stubs(:active_assignments).returns([])
      subject = TrainingCompliance.new([employee_record])

      result = subject.percentage

      assert_equal 0, result
    end

    test 'when all assignments have been completed' do
      employee_record = build(:employee_record)
      employee_record.stubs(:incomplete_assignments).returns([])
      employee_record.stubs(:active_assignments).returns([1])
      subject = TrainingCompliance.new([employee_record])

      result = subject.percentage

      assert_equal 100, result
    end

    test 'when half of the assignments have been completed' do
      employee_record = build(:employee_record)
      employee_record.stubs(:incomplete_assignments).returns([1])
      employee_record.stubs(:active_assignments).returns([1, 2])
      subject = TrainingCompliance.new([employee_record])

      result = subject.percentage

      assert_equal 50, result
    end

    test 'when one third of the assignments have been completed' do
      employee_record = build(:employee_record)
      employee_record.stubs(:incomplete_assignments).returns([1, 2])
      employee_record.stubs(:active_assignments).returns([1, 2, 3])
      subject = TrainingCompliance.new([employee_record])

      result = subject.percentage

      assert_equal 33, result
    end
  end
end
