class CoursePresenter < ModelPresenter
  presents :course
  delegate :title, :code, :description, :max_test_retakes, :active?,
           :passing_threshold_percentage, :questions, :deactivated?,
           :material_file_name, :material_type, :material_url,
           :supplement_filenames, :canned?, :custom?, :days_due_within,
            to: :course

  def certificate_type
    course.certificate_type.upcase
  end

  def confirm_deactivate_message
    "NOTE: Deactivating will remove this course from all tracks."
  end

  def status
    if course.active?
      'Active'
    else
      'Deactivated'
    end
  end

  def when_no_questions_exist(&block)
    unless course.questions.any?
      yield
    end
  end

  def when_user_can_delete_choice(choice_policy, &block)
    if choice_policy.destroy?
      yield
    end
  end

  def states
    if course.states.any?
      course.states.join(", ")
    else
      'N/A'
    end
  end

  def supplements_list
    if course.supplements.any?
      supplement_filenames.join(', ')
    else
      'N/A'
    end
  end

  def days_due_within
    if course.days_due_within.present?
      pluralize(course.days_due_within, 'day')
    else
      'N/A'
    end
  end

  def unassigned_employees(account)
    employee_records = account.unassigned_employees_for_course(course)
    EmployeeRecordsPresenter.new(employee_records, current_user).group_by do |erp|
      erp.office_name
    end.sort_by { |k, v| k }.to_h
  end

  def total_assigned(account)
    account
      .assignments_for_course(course)
      .count
  end

  def total_passed(account)
    account
      .passed_assignments_for_course(course)
      .count
  end

  def assignments(account)
    assignments_for_account =
      AssignmentsForCourseWithAccount.new(course.id, account.id).query

    AssignmentsPresenter.new(assignments_for_account, current_user)
  end

  def compliance_expiration_in_days
    course.compliance_expiration_in_days.humanize
  end

  def show_path
    course_path(course)
  end

  def edit_path
    edit_course_path(course)
  end

  def preview_path
    preview_course_path(course)
  end

  def new_question_path
    new_course_question_path(course)
  end

  def assignments_path
    assignments_course_path(course)
  end

  def deactivate_path
    deactivate_course_path(course)
  end

  def reactivate_path
    reactivate_course_path(course)
  end

  def download_supplements_path
    supplements_course_path(course)
  end
end
