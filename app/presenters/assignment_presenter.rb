class AssignmentPresenter < ModelPresenter
  presents :assignment
  delegate :course_title, :course_description, :course_material_url,
           :course_material_type, :state, :employee_record_full_name,
           :employee_record_last_comma_first, :days_expires_in,
            to: :assignment

  attr_accessor :maybe_track

  def due_date_with_days_past_due
    return nil unless show_due_date?

    due_date = I18n.localize(assignment.due_date, format: :default)
    days_until_due = assignment.days_until_due
    days_until_due_formatted = pluralize(days_until_due.abs, 'day')

    if days_until_due < 0
      content_tag(:span, class: "text-danger") do
        "#{due_date} (#{days_until_due_formatted} past due)"
      end
    elsif days_until_due == 0
      "#{due_date} (due today)"
    else
      "#{due_date} (#{days_until_due_formatted})"
    end
  end

  def when_expiring_soon(&block)
    if assignment.expiring_soon?
      yield
    end
  end

  def prevent_fwd_seeking?
    user_can?(:take_exam)
  end

  def show_continue_modal?
    user_can?(:take_exam)
  end

  def when_course_has_supplements(&block)
    if assignment.course_supplements.any?
      yield
    end
  end

  def action(&block)
    action = assignment.action(maybe_track)
    yield(action.text, action.path)
  end

  def action_btn_class
    if assignment.new? || assignment.failed?
      'btn-success'
    elsif assignment.expiring_soon?
      'btn-warning'
    elsif assignment.expired?
      'btn-danger'
    else
      'btn-primary'
    end
  end

  def material_content_partial
    if 'pdf' == course_material_type
      'pdf_content'
    else
      'video_content'
    end
  end

  def state_tag
    tag_type = { 'new'    => 'tag-info',
                 'passed' => 'tag-success',
                 'failed' => 'tag-danger',
                 'expired' => 'tag-danger',
               }.fetch(state, 'tag-grey')

    content_tag(:span, class: "tag tag-default #{tag_type} font-small-1 valign-middle") do
      state.downcase
    end
  end

  def mark_completed_btn
    data = {
      toggle: 'modal',
      target: '#mark-assignment-completed-modal',
      assignment_id: id,
      employee_name: employee_record_full_name,
      course_title: course_title,
    }
    classes = 'btn btn-success btn-sm mark-assignment-completed-btn'

    ActionController::Base.helpers.link_to('#mark-assignment-completed-modal', data: data, class: classes) do
      content_tag(:i, '', class: 'icon-check white')
    end
  end

  def delete_path
    assignment_path(assignment)
  end

  def show_path
    assignment_path(assignment)
  end

  def new_exam_path
    new_assignment_exam_path(assignment)
  end

  def download_material_path
    download_assignment_path(assignment)
  end

  def download_supplements_path
    supplements_course_path(assignment.course)
  end

  def show_employee_record_path
    employee_record_path(assignment.employee_record)
  end

  def mark_completed_path
    mark_completed_assignment_path(assignment)
  end

  private

  def show_due_date?
    if !assignment.expirable? && assignment.due_date.blank?
      false
    elsif !assignment.expirable? && assignment.due_date.present?
      true
    elsif assignment.expirable? && (assignment.expiring_soon? || assignment.expired?)
      true
    elsif assignment.expirable? && (!assignment.expiring_soon? && !assignment.expired?)
      assignment.due_date.present?
    end
  end
end
