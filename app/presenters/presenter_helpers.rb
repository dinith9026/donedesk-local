module PresenterHelpers
  def when_user_can(action, &block)
    if user_can?(action)
      yield
    end
  end

  def when_user_cannot(action, &block)
    unless user_can?(action)
      yield
    end
  end

  def user_can?(action)
    policy.public_send("#{action}?")
  end

  def editable?(field)
    policy.permitted_attributes.include?(field)
  end

  def when_user_can_edit(field, &block)
    if editable?(field)
      yield if block_given?
    end
  end

  def viewable?(field)
    policy.permitted_attributes.include?(field)
  end

  def when_user_can_view(field, &block)
    if viewable?(field)
      yield
    end
  end

  def when_user_cannot_edit(field, &block)
    unless editable?(field)
      yield if block_given?
    end
  end
end
