require 'test_helper'

class ManageCoursesTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)
    @assigned_course = courses(:oceanview_handbook)
    @unassigned_course = courses(:oceanview_unassigned)
    sign_in_with(@user)
    click_on 'Courses'
  end

  test 'listing' do
    deactivated_canned = courses(:canned_deactivated)

    refute_content deactivated_canned.title
    assert_content @assigned_course.title
  end

  test 'create' do
    values = valid_course_values

    click_on 'New Course'

    fill_in_and_submit_form_with(values)

    assert_course values
  end

  test 'add a question with choices' do
    question_text = 'Did you take the course?'

    visit course_path(@unassigned_course)

    click_on 'New Question'

    fill_in 'question_text', with: question_text
    fill_in 'question[choices][0][answer]', with: 'Yes'
    choose 'question[choices][0][is_correct]'
    fill_in 'question[choices][1][answer]', with: 'No'
    click_on 'Save'

    assert_content 'Success'
    assert_content question_text
  end

  test 'deactivate' do
    click_on @assigned_course.title
    click_on 'Deactivate'
    click_on 'Yes, deactivate it'

    assert_content 'Success'
    assert find("a[href=\"#{reactivate_course_path(@assigned_course)}\"]")
  end

  private

  def valid_course_values
    attributes_for(:course).merge({ material: 'test/fixtures/test.pdf' })
  end

  def fill_in_and_submit_form_with(values)
    fill_in 'course_title', with: values[:title]
    fill_in 'course_code', with: values[:code]
    fill_in 'course_description', with: values[:description]
    select values[:compliance_expiration_in_days].humanize, from: 'course_compliance_expiration_in_days'
    fill_in 'course_max_test_retakes', with: values[:max_test_retakes]
    fill_in 'course_passing_threshold_percentage', with: values[:passing_threshold_percentage]
    find('#course_material_s3_key', visible: false).set(values[:material_s3_key]) # cheat to skip file uploading (hard to test)
    click_button 'Save'
  end

  def assert_course(values)
    assert_content values[:title]
    assert_content values[:code]
    assert_content values[:description]
    assert_content values[:compliance_expiration_in_days].humanize
    assert_content values[:max_test_retakes]
    assert_content "#{values[:passing_threshold_percentage]}%"
    assert_content File.basename(values[:material])
  end
end
