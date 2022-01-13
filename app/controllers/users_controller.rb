class UsersController < Clearance::UsersController
  def index
    authorize User
    result = User.where("CONCAT_WS(first_name, last_name, email, ' ') ILIKE ?", "%#{params[:query]}%")

    users = result.map do |user|
      { label: "#{user.full_name} - #{user.email} (#{user.account_name})" , value: user.id }
    end.flatten.compact.to_json

    respond_to do |format|
      format.json { render json: users }
    end
  end

  def show
    user = find_user
    authorize user

    @user_presenter = UserPresenter.new(user, policy(user))
  end

  def edit
    user = find_user
    authorize user

    @form =
      UserForm
      .from_model(user)
      .with_context(user: user)
      .with_policy(policy(user))
  end

  def update
    user = find_user
    authorize user

    @form =
      UserForm
      .from_params(user_params, id: user.id)
      .with_context(user: user)
      .with_policy(policy(user))

    UpdateUser.call(@form, user) do
      on(:ok)      { |user| set_flash_success_and_redirect_to(url_after_update(user)) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def make_account_manager
    user = find_user
    authorize user, :make_account_manager?

    user.change_role_to!('account_manager')
  end

  def make_employee
    user = find_user
    authorize user, :make_employee?

    user.change_role_to!('employee')
  end

  def reinvite
    user = find_user
    authorize user

    UserMailer.employee_invite_email(user).deliver_later

    set_flash_success_and_redirect_to(employee_records_url)
  end

  def destroy
    user = find_user
    authorize user

    user.destroy!

    set_flash_success_and_redirect_to(employee_records_url)
  end

  private

  def user_params
    params.require(:user).permit(policy(User.new).permitted_attributes)
  end

  def find_user
    if current_user.super_admin?
      User.find(params[:id])
    else
      FindUserForAccount.new(current_account, params[:id]).query
    end
  end

  def url_after_update(user)
    smart_back_path
  end
end
