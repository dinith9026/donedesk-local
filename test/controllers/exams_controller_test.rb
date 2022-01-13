require 'test_helper'

class ExamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assignment = assignments(:oceanview_handbook_for_employee)
    @other_assignment = assignments(:brookside_handbook)
    @exam = exams(:failed_for_oceanview_handbook_for_employee)
    @another_exam = exams(:another_exam)
    @user = @assignment.user
  end

  describe '#new' do
    it_requires_authenticated_user do
      get new_assignment_exam_url(assignment_id: @assignment.id)
    end

    test 'for account owner it restricts access' do
      get new_assignment_exam_url(as: users(:account_owner),
                                  assignment_id: @assignment.id)

      assert_redirects_with_not_authorized_error
    end

    describe 'for employee' do
      test 'when assignment does NOT belong to their account' do
        get new_assignment_exam_url(as: @user, assignment_id: @other_assignment.id)

        assert_redirects_with_not_found_error
      end

      test 'when assignment belongs to their account' do
        get new_assignment_exam_url(as: @user, assignment_id: @assignment.id)

        assert_response :success
        refute_nil assigns[:form]
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user do
      post assignment_exams_url(assignment_id: @assignment.id)
    end

    test 'for account owner it restricts access' do
      post assignment_exams_url(as: users(:account_owner),
                                assignment_id: @assignment.id)

      assert_redirects_with_not_authorized_error
    end

    describe 'for employee' do
      test 'when assignment does NOT belong to their account' do
        post assignment_exams_url(as: @user, assignment_id: @other_assignment.id)

        assert_redirects_with_not_found_error
      end

      describe 'when assignment belongs to their account' do
        test 'when params are valid and exam passed' do
          assert_difference ['Exam.count', 'Certificate.count'], 1 do
            post assignment_exams_url(as: @user, assignment_id: @assignment.id),
                 params: { exam: valid_passing_params }
          end
          assert_response :redirect
          assert_redirected_to exam_url(last_exam)
        end

        test 'when params are valid and exam failed' do

          assert_difference 'Exam.count', 1 do
            assert_no_difference 'Certificate.count' do
              post assignment_exams_url(as: @user, assignment_id: @assignment.id),
                   params: { exam: valid_failing_params }
            end
          end
          assert_response :redirect
          assert_redirected_to exam_url(last_exam)
        end

        test 'when params are NOT valid' do
          assert_no_difference 'Exam.count', 1 do
            post assignment_exams_url(as: @user, assignment_id: @assignment.id),
                 params: { exam: invalid_params }
          end
          assert_response :success
          refute_nil flash[:error]
          refute_nil assigns[:form]
          assert_template :new
        end
      end
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get exam_url(@exam) }

    describe 'for account owner' do
      test 'when exam does not belong to their account' do
        get exam_url(@exam, as: users(:another_account_owner))

        assert_redirects_with_not_found_error
      end

      test 'when exam belongs to their account' do
        get exam_url(@exam, as: users(:account_owner))

        assert_redirects_with_not_authorized_error
      end
    end

    describe 'for employee' do
      test 'when exam does NOT belong to them' do
        get exam_url(@another_exam, as: @user)

        assert_redirects_with_not_found_error
      end

      test 'when exam belongs to them' do
        get exam_url(@exam, as: @user)

        assert_response :success
        refute_nil assigns[:exam_presenter]
      end

      test 'when exam belongs to a canned course' do
        exam = exams(:for_oceanview_canned)

        get exam_url(exam, as: @user)

        assert_response :success
        refute_nil assigns[:exam_presenter]
      end
    end
  end

  private

  def valid_passing_params
    answers = {}

    @assignment.course_questions.each_with_index do |q, i|
      answers[i] = {
        question_id: q.id,
        choice_id: q.correct_choice.id
      }
    end

    { answers: answers }
  end

  def valid_failing_params
    answers = {}

    @assignment.course_questions.each_with_index do |q, i|
      answers[i] = {
        question_id: q.id,
        choice_id: q.choices.find { |c| !c.is_correct }.id
      }
    end

    { answers: answers }
  end

  def invalid_params
    {
      answers: { "0" => { question_id: nil, choice_id: nil } }
    }
  end

  def last_exam
    Exam.order(:created_at).last
  end
end
