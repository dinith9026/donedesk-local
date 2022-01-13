require 'test_helper'

class ChoicePolicyTest < PolicyTest
  describe '#destroy?' do
    test 'when question has less than 3 choices' do
      user = build(:user)
      question = build(:question, choices: build_list(:choice, 2))
      choice = question.choices.first

      refute_permit(:destroy, user, choice)
    end

    describe 'when question has more than 2 choices' do
      test 'and given choice is correct' do
        user = build(:user)
        question = build(:question, choices: build_list(:choice, 3))
        choice = question.choices.first
        choice.is_correct = true

        refute_permit(:destroy, user, choice)
      end

      describe 'and given choice is wrong' do
        test 'and user role is not a super admin or account admin' do
          user = build(:user, :employee)
          question = build(:question, choices: build_list(:choice, 3))
          choice = question.choices.first
          choice.is_correct = false

          refute_permit(:destroy, user, choice)
        end

        describe 'and user role is account admin' do
          test 'and course does NOT belong to account' do
            user = build(:user, :account_owner)
            question = build(:question, choices: build_list(:choice, 3))
            choice = question.choices.first
            choice.is_correct = false
            course_stub = Struct.new(:account_id).new('not matching')
            choice.stubs(:question_course).returns(course_stub)

            refute_permit(:destroy, user, choice)
          end

          test 'and course belongs to account' do
            user = build(:user, :account_owner)
            question = build(:question, choices: build_list(:choice, 3))
            choice = question.choices.first
            choice.is_correct = false
            user.stubs(:account_id).returns('matching')
            course_stub = Struct.new(:account_id).new('matching')
            choice.stubs(:question_course).returns(course_stub)

            assert_permit(:destroy, user, choice)
          end
        end
      end
    end
  end
end
