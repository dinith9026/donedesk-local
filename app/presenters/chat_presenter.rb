class ChatPresenter < ModelPresenter
  presents :chat
  delegate :other_user, :other_user_id, :other_user_full_name, :other_user_email,
    :other_user_gravatar_url, :other_user_role, to: :chat

  def when_other_user_present(&block)
    if other_user.present?
      yield
    end
  end

  def when_other_user_not_present(&block)
    if other_user.blank?
      yield
    end
  end

  def account_users_json
    chat.account_users.map do |user|
      if chat.current_user.id != user.id
        { label: user.full_name, value: user.id }
      end
    end.flatten.compact.to_json
  end
end
