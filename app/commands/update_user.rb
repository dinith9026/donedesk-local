class UpdateUser < ApplicationCommand
  def initialize(form, user, name_syncer = SyncName)
    @form = form
    @user = user
    @name_syncer = name_syncer
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    user_attrs = {
      avatar: @form.avatar,
      first_name: @form.first_name,
      last_name: @form.last_name,
      email: @form.email,
      two_factor_enabled: @form.two_factor_enabled,
    }

    if @form.avatar.present?
      user_attrs = user_attrs.merge(avatar: @form.avatar)
    end

    @user.update!(user_attrs)

    if @user.employee_record.present?
      @name_syncer.call(newer: @user, older: @user.employee_record)
    end

    broadcast(:ok, @user)
  end
end
