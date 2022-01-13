class ChoicePolicy < ApplicationPolicy
  def destroy?
    return false if record.question.choices.size < 3 || record.is_correct

    if user.super_admin?
      true
    elsif user.account_admin? && choice_belongs_to_user_account
      true
    else
      false
    end
  end

  private

  def choice_belongs_to_user_account
    record.question_course.account_id == user.account_id
  end
end
