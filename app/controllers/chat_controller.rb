class ChatController < ApplicationController
  def show
    chat = Chat.new(
      current_user: current_user,
      other_user: other_user,
      account_users: ActiveAccountUsers.new(current_account).query
    )

    authorize chat

    @chat_presenter = ChatPresenter.new(chat, policy(chat))

    unless current_user.has_accepted_chat_terms?
      redirect_to chat_terms_url, notice: 'You must first read and agree to the chat TOS before using the chat.'
    end
  end

  private

  def other_user
    user_id ? current_account.users.find(user_id) : nil
  end

  def user_id
    params[:user_id]
  end
end
