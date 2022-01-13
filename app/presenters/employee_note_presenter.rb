class EmployeeNotePresenter < ModelPresenter
  include ActionView::Helpers::TextHelper

  presents :employee_note
  delegate :creator_full_name, to: :employee_note

  def html_body
    simple_format(employee_note.body)
  end

  def created_on
    I18n.localize(employee_note.created_at.to_date, format: :default)
  end
end
