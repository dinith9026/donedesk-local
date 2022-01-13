class AcceptChatTerms < ApplicationCommand
  def initialize(user, ip_address)
    @user = user
    @ip_address = ip_address
  end

  def call
    chat_terms = {
      accepted_at: Time.now.utc,
      ip_address: @ip_address
    }

    @user.update!(chat_terms: chat_terms)

    broadcast(:ok)
  end
end
