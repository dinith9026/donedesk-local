class MigrateEmployee < ApplicationCommand
  def initialize(employee_record, new_office)
    @employee_record = employee_record
    @new_office = new_office
  end

  def call
    old_account = @employee_record.account
    new_account = @new_office.account

    old_account_course_titles = old_account.custom_courses.map(&:title).map(&:upcase)
    new_account_course_titles = new_account.custom_courses.map(&:title).map(&:upcase)

    missing_courses = old_account_course_titles - new_account_course_titles

    old_account_document_type_names = old_account.document_types.for_employees.map(&:name).map(&:upcase)
    new_account_document_type_names = new_account.document_types.for_employees.map(&:name).map(&:upcase)

    missing_document_types = old_account_document_type_names - new_account_document_type_names

    if missing_courses.any? || missing_document_types.any?
      broadcast(:mismatch, missing_courses + missing_document_types)
    else
      transaction do
        @employee_record.user.update!(account_id: new_account.id)
        @employee_record.update!(office_id: @new_office.id)

        @employee_record.assignments.each do |assignment|
          next if assignment.course.is_canned?

          old_course = assignment.course
          new_course = new_account.custom_courses.find do |course|
            old_course.title.upcase == course.title.upcase
          end
          assignment.course_id = new_course.id
          assignment.save!(validate: false)
        end

        @employee_record.documents.each do |document|
          next if document.document_type.is_canned?

          old_doctype = document.document_type
          new_doctype = new_account.document_types.find do |doctype|
            old_doctype.name.upcase == doctype.name.upcase
          end
          document.document_type_id = new_doctype.id
          document.save!(validate: false)
        end
      end

      broadcast(:ok)
    end
  end
end
