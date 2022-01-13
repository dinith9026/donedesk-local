require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @another_account = accounts(:brookside_dental)

    @account_owner = users(:account_owner)
    @employee_user = users(:employee)

    @course = courses(:oceanview_handbook)
    @another_course = courses(:brookside_handbook)
    @question = @course.questions.first
    @another_question = @another_course.questions.first
  end

  describe '#new' do
    it_requires_authenticated_user { get new_course_question_url(@course) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        get new_course_question_url(as: @account_owner, course_id: @another_course.id)

        assert_redirects_with_not_found_error
      end

      test 'when record does belong to their account' do
        get new_course_question_url(as: @account_owner, course_id: @course.id)

        assert_response :success
        assert_template :new
        assert_equal @course, assigns[:course]
        refute_nil assigns[:form]
      end
    end

    test 'for employee it restricts access' do
      get new_course_question_url(@course, as: @employee_user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post course_questions_url(@course) }

    describe 'for account_owner' do
      test 'when params are invalid' do
        assert_no_difference 'Question.count' do
          post course_questions_url(as: @account_owner, course_id: @course.id),
                params: { question: invalid_params }
        end
        assert_response :success
        assert_template :new
        refute_nil flash[:error]
        assert_equal @course, assigns[:course]
        refute_nil assigns[:form]
      end

      test 'when params are valid' do
        assert_difference 'Question.count', 1 do
          post course_questions_url(as: @account_owner, course_id: @course.id),
                params: { question: valid_params }
        end
        assert_redirected_to course_url(@course)
        refute_nil flash[:success]
        assert_equal valid_params[:choices].count, last_question.choices.count
      end
    end

    test 'for employee it restricts access' do
      post course_questions_url(as: @employee_user, course_id: @course.id),
            params: { question: valid_params }

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_question_url(@question) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        get edit_question_url(@another_question, as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      test 'when record belongs to their account' do
        get edit_question_url(@question, as: @account_owner)

        assert_response :success
        assert_template :edit
        refute_nil assigns[:form]
        refute_nil assigns[:course]
      end
    end

    test 'for employee it restricts access' do
      get edit_question_url(@question, as: @employee_user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put question_url(@question) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        put question_url(@another_question, as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      describe 'when record belongs to their account' do
        test 'when params are VALID' do
          new_question_text = SecureRandom.hex
          question_params = {
            text: new_question_text,
            choices: valid_choices_params
          }

          put question_url(@question, as: @account_owner),
                params: { question: question_params }

          assert_response :redirect
          assert_redirected_to course_path(@question.course)
          refute_nil flash[:success]
          assert_equal new_question_text, @question.reload.text
        end
      end
    end

    test 'for employee it restricts access' do
      get edit_question_url(@question, as: @employee_user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete question_url(@question) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        delete question_url(@another_question, as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      describe 'when record does belong to their account' do
        test 'when course is assigned and has one question' do
          assert_no_difference 'Question.count' do
            delete question_url(@question, as: @account_owner)
          end
          assert_response :redirect
          assert_redirected_to @question.course
          refute_nil flash[:error]
        end

        test 'when course is NOT assigned and has one question' do
          @question.course.assignments.destroy_all

          assert_difference 'Question.count', -1 do
            delete question_url(@question, as: @account_owner)
          end
          assert_response :redirect
          assert_redirected_to @question.course
          refute_nil flash[:success]
        end
      end
    end

    test 'for employee it restricts access' do
      delete question_url(@question, as: @employee_user)

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    attributes_for(:question, choices: valid_choices_params)
  end

  def valid_choices_params
    {
      0 => attributes_for(:choice, is_correct: true),
      1 => attributes_for(:choice, is_correct: false),
    }
  end

  def invalid_params
    { text: '' }
  end

  def last_question
    Question.order(:created_at).last
  end
end
