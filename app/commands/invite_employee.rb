class InviteEmployee < ApplicationCommand
  def initialize(account, employee_record, form)
    @account = account
    @employee_record = employee_record
    @form = form
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    transaction do
      user = User.create!(user_attributes)
      user.forgot_password!
      @employee_record.update!(user_id: user.id)

      UserMailer.employee_invite_email(user).deliver_later
    end

    broadcast(:ok)
  end

  private

  def user_attributes
    @form.attributes.merge(
      account_id: @account.id,
      first_name: @employee_record.first_name,
      last_name: @employee_record.last_name,
      password: User.generate_valid_password,
    )
  end
end
