module PresenterHelperTests
  describe '#when_user_can' do
    test 'when authorized' do
      policy_stub = Struct.new(:index?).new(true)
      subject = ApplicationForm.new.with_policy(policy_stub)
      block_called = false

      subject.when_user_can(:index) do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when not authorized' do
      policy_stub = Struct.new(:index?).new(false)
      subject = ApplicationForm.new.with_policy(policy_stub)
      block_called = false

      subject.when_user_can(:index) do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#user_can?' do
    test 'when authorized' do
      policy_stub = Struct.new(:index?).new(true)
      subject = ApplicationForm.new.with_policy(policy_stub)

      result = subject.user_can?(:index)

      assert_equal true, result
    end

    test 'when not authorized' do
      policy_stub = Struct.new(:index?).new(false)
      subject = ApplicationForm.new.with_policy(policy_stub)

      result = subject.user_can?(:index)

      assert_equal false, result
    end
  end
end
