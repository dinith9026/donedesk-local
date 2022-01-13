module DeactivateableTests
  def test_is_not_considered_active_when_deactivated
    @subject.deactivated_at = DateTime.current

    assert_equal false, @subject.active?
  end

  def test_is_considered_active_when_not_deactivated
    @subject.deactivated_at = nil

    assert_equal true, @subject.active?
  end

  def test_is_not_considered_deactivated_when_active
    @subject.deactivated_at = nil

    assert_equal false, @subject.deactivated?
  end

  def test_is_not_considered_deactivated_when_active
    @subject.deactivated_at = DateTime.current

    assert_equal true, @subject.deactivated?
  end

  def test_successful_deactivation
    @subject.update!(deactivated_at: nil)

    @subject.deactivate!

    refute_nil @subject.reload.deactivated_at
  end

  def test_successful_reactivation
    @subject.update!(deactivated_at: DateTime.current)

    @subject.reactivate!

    assert_nil @subject.reload.deactivated_at
  end
end
