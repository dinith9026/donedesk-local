class CurrentUserController < ApplicationController
  before_action :skip_authorization, only: [:show, :edit, :update, :chat_terms, :accept_chat_terms]

  def show
    @user_presenter = UserPresenter.new(current_user, policy(current_user))
  end

  def edit
    @form =
      UserForm
      .from_model(current_user)
      .with_context(user: current_user)
      .with_policy(policy(current_user))
  end

  def update
    @form =
      UserForm
      .from_params(user_params, id: current_user.id)
      .with_context(user: current_user)
      .with_policy(policy(current_user))

    UpdateUser.call(@form, current_user) do
      on(:ok)      { set_flash_success_and_redirect_to(profile_path) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def chat_terms
  end

  def accept_chat_terms
    AcceptChatTerms.call(current_user, request.remote_ip) do
      on(:ok) { redirect_to chat_url }
    end
  end

  private

  def user_params
    params.require(:user).permit(policy(User.new).permitted_attributes)
  end
end
