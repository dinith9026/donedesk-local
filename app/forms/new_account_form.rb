class NewAccountForm < BaseAccountForm
  mimic :account

  attribute :office, OfficeForm
  attribute :user, UserForm
  attribute :plan, PlanForm

  validate :plan_form_is_valid
  validate :user_form_is_valid
  validate :office_form_is_valid

  def document_group_presets
    context.document_group_presets
  end

  private

  def office_form_is_valid
    if office && office.invalid?
      merge_errors_for(:office)
    end
  end

  def user_form_is_valid
    if user && user.invalid?
      merge_errors_for(:user, 'owner')
    end
  end

  def plan_form_is_valid
    if plan&.invalid?
      merge_errors_for(:plan)
    end
  end
end
