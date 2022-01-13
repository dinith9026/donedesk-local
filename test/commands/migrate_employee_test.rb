require 'test_helper'

class MigrateEmployeeTest < CommandTest
  setup do
    @old_account = create(:account)
    @new_account = create(:account)
    @new_office = @new_account.offices.first
    @document_group = create_employee_document_group_for(@new_account)

    @old_account_course = create(:course, :with_question, account: @old_account)
    @old_account_doctype = create(:document_type, account: @old_account)

    @user = create(:user, account: @old_account)
    @employee_record =
      create(
        :employee_record,
        user: @user,
        office: @old_account.offices.first,
        document_group: @document_group
    )
  end

  test "when custom courses and doc types DO NOT match up with new account" do
    assert_broadcast(:mismatch) do
      MigrateEmployee.call(@employee_record, @new_office)
    end
  end

  test "when custom courses and doc types match up with new account" do
    new_account_course = create(
      :course,
      title: @old_account_course.title.downcase, # To test case-insensitivity
      account: @new_account
    )

    assignment = create(
      :assignment,
      employee_record: @employee_record,
      course: @old_account_course
    )

    # Ensure canned courses are skipped
    create(
      :assignment,
      employee_record: @employee_record,
      course: courses(:canned)
    )

    new_account_doctype = create(
      :document_type,
      name: @old_account_doctype.name.downcase,
      account: @new_account
    )

    document = create(
      :document,
      document_type: @old_account_doctype
    )

    create(
      :employee_document,
      employee_record: @employee_record,
      document: document
    )

    # Ensure canned doctypes are skipped
    canned_document = create(
      :document,
      document_type: document_types(:w4)
    )

    create(
      :employee_document,
      employee_record: @employee_record,
      document: canned_document
    )

    assert_broadcast(:ok) do
      MigrateEmployee.call(@employee_record, @new_office)
    end
    assert_equal @employee_record.reload.account_name, @new_account.name
    assert_equal @employee_record.office_id, @new_account.offices.first.id
    assert_equal assignment.reload.course_id, new_account_course.id
    assert_equal document.reload.document_type_id, new_account_doctype.id
  end
end
