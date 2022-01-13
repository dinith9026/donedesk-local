class UpdateEmployeeRecord < ApplicationCommand
  def initialize(form, employee_record)
    @form = form
    @employee_record = employee_record
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    transaction do
      @employee_record.update!(@form.attributes)

      if @employee_record.user.present?
        user_attrs = {
          first_name: @employee_record.first_name,
          last_name: @employee_record.last_name,
          email: @form.user.email,
          role: @employee_record.user.role
        }

        if @form.user.avatar.present?
          user_attrs = user_attrs.merge(avatar: @form.user.avatar)
        end

        @employee_record.user.update!(user_attrs)
      end
    end

    broadcast(:ok, @employee_record)
  end
end
