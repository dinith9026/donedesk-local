class UpdateCourse < ApplicationCommand
  def initialize(form, course, account)
    @form = form
    @course = course
    @account = account
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    attrs = @form.attributes.tap do |attributes|
      attributes[:account_id] = @form.is_canned ? nil : @account.id
    end

    @course.update!(attrs)

    broadcast(:ok, @course)
  end
end
