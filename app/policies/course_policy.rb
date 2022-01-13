class CoursePolicy < ApplicationPolicy
  def show?
    if user.super_admin?
      true
    elsif user.account_admin? && record.canned? && record.deactivated?
      false
    elsif user.account_admin?
      true
    elsif user.employee?
      false
    else
      false
    end
  end

  def update?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def preview?
    if user.super_admin?
      true
    elsif user.account_admin? && (record_owned_by_account? || record.canned?)
      true
    else
      false
    end
  end

  def assign?
    if record.deactivated? || record.questions.empty? || account.employee_records.empty?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && (record_owned_by_account? || record.canned?)
      true
    else
      false
    end
  end

  def new_question?
    if record.deactivated?
      false
    elsif record.question_limit_reached?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def edit_question?
    update_question?
  end

  def update_question?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def destroy_question?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def download_supplements?
    if user.super_admin?
      true
    elsif (user.account_admin? || user.employee?) && (record_owned_by_account? || record.canned?)
      true
    else
      false
    end
  end

  def destroy_supplement?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def deactivate?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def reactivate?
    if user.super_admin? && record.deactivated?
      true
    elsif user.account_admin? && record_owned_by_account? && record.deactivated?
      true
    else
      false
    end
  end

  def permitted_attributes
    permitted = [:account_id, :title, :code, :description, :compliance_expiration_in_days,
       :max_test_retakes, :passing_threshold_percentage, :material_s3_key, :supplements,
       :days_due_within]

    if user.super_admin?
      permitted += [:is_canned, :states, :certificate_type]
    end

    permitted
  end
end
