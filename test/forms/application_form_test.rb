require 'test_helper'
require_relative '../presenters/presenter_helper_tests'

class ApplicationFormTest < ActiveSupport::TestCase
  include PresenterHelperTests

  class TestForm < ApplicationForm
    attribute :foo
    attribute :bar
  end

  describe "#attributes" do
    test "when no policy exists" do
      subject = TestForm.new

      assert_equal subject.attributes, { foo: nil, bar: nil }
    end

    describe "when policy exists" do
      test "and permitted_attributes are NOT defined" do
        policy_stub = Object.new
        subject = TestForm.new.with_policy(policy_stub)

        assert_equal subject.attributes, { foo: nil, bar: nil }
      end

      test "and permitted_attributes are defined" do
        policy_stub = Struct.new(:permitted_attributes).new([:foo])
        subject = TestForm.new.with_policy(policy_stub)

        assert_equal subject.attributes, { foo: nil }
      end
    end
  end

  describe '#when_user_can_edit' do
    test 'when policy permits editing' do
      block_called = false
      policy_stub = Struct.new(:permitted_attributes).new([:hired_on])
      subject = ApplicationForm.new.with_policy(policy_stub)

      subject.when_user_can_edit(:hired_on) do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when policy forbids editing' do
      block_called = false
      policy_stub = Struct.new(:permitted_attributes).new([])
      subject = ApplicationForm.new.with_policy(policy_stub)

      subject.when_user_can_edit(:hired_on) do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#when_user_cannot_edit' do
    test 'when policy permits editing' do
      block_called = false
      policy_stub = Struct.new(:permitted_attributes).new([:hired_on])
      subject = EmployeeRecordForm.new.with_policy(policy_stub)

      subject.when_user_cannot_edit(:hired_on) do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when policy forbids editing' do
      block_called = false
      policy_stub = Struct.new(:permitted_attributes).new([])
      subject = EmployeeRecordForm.new.with_policy(policy_stub)

      subject.when_user_cannot_edit(:hired_on) do
        block_called = true
      end

      assert_equal true, block_called
    end
  end
end
