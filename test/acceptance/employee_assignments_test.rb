require 'test_helper'

class EmployeeAssignmentsTest < AcceptanceTestCase
  setup do
    @account = accounts(:oceanview_dental)
    @user = users(:employee)

    sign_in_with(@user)
  end

  test 'view all assignments' do
    click_on 'Assignments'

    @user.employee_record.active_assignments.each do |assignment|
      assert_content assignment.course.title
      assert_content assignment.state
    end
  end

  test 'take course with PDF material' do
    course = create_course_with_assignment(material_s3_key: 'doc.pdf')
    assignment = course.assignments.first

    click_on 'Assignments'
    take_course_link_for(assignment).click

    assert_content course.title
    assert_content course.description
    assert_includes pdf_object_data, course.material_file_name
  end

  test 'take course with video material' do
    course = create_course_with_assignment(material_s3_key: 'video.mp4')
    assignment = course.assignments.first

    click_on 'Assignments'
    take_course_link_for(assignment).click

    assert_content course.title
    assert_content course.description
    assert_includes video_src, course.material_file_name
  end

  test 'take exam' do
    course = create_course_with_assignment(material_s3_key: 'doc.pdf')
    assignment = course.assignments.first

    click_on 'Assignments'
    take_course_link_for(assignment).click
    within '.card-header' do
      click_on 'Take Exam'
    end

    course.questions.each_with_index do |question, i|
      choice = question.correct_choice
      choose choice.answer
    end
    click_on 'Submit'

    assert_content 'Congratulations'
  end

  private

  def take_course_link_for(assignment)
    find_link('Take Course', href: /#{assignment_path(assignment)}/i)
  end

  def pdf_object_data
    find('object[type="application/pdf"]')['data']
  end

  def video_src
    find('#video-material')['src']
  end

  def create_course_with_assignment(material_s3_key:)
    course = create(:course, :with_question, account: @account, material_s3_key: material_s3_key)
    create(
      :assignment,
      :new,
      employee_record: @user.employee_record,
      course: course
    )

    course
  end
end
