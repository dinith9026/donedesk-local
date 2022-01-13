class CreateCourse < ApplicationCommand
  def initialize(account, form)
    @account = account
    @form = form
  end

  def call
    if @form.is_canned
      @form.account_id = nil
    else
      @form.account_id = @account.id
    end

    return broadcast(:invalid) if @form.invalid?

    transaction do
      course = Course.create!(@form.attributes)
      broadcast(:ok, course)
    end
  end
end
