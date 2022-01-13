class Chat
  include ActiveModel::Model
  attr_accessor :current_user, :other_user, :account_users

  delegate :id, :full_name, :email, :gravatar_url, :role, to: :other_user, prefix: true
end
