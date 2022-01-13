require 'test_helper'

class CoursePolicyTest < PolicyTest
  describe '#show?' do
    test 'as a super admin' do
      user = users(:super_admin)
      canned = courses(:canned_deactivated)

      assert_permit(:show, user, canned)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        custom = courses(:oceanview_handbook)
        custom.deactivate!
        canned = courses(:canned_deactivated)

        refute_permit(:show, user, canned)
        assert_permit(:show, user, custom)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      course = courses(:oceanview_handbook)

      refute_permit(:show, user, course)
    end
  end

  describe '#update?' do
    test 'when course is deactivated' do
      deactivated_course = Struct.new(:deactivated?).new(true)

      refute_permit(:update, nil, deactivated_course)
    end

    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:edit, user, Course.new)
      assert_permit(:update, user, Course.new)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        custom_course = Struct.new(:deactivated?, :account_id).new(false, user.account_id)
        canned_course = Struct.new(:deactivated?, :account_id).new(false, nil)

        assert_permit(:edit, user, custom_course)
        assert_permit(:update, user, custom_course)
        refute_permit(:edit, user, canned_course)
        refute_permit(:update, user, canned_course)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:edit, user, Course.new)
      refute_permit(:update, user, Course.new)
    end
  end

  describe '#preview?' do
    test 'as a super admin' do
      user = users(:super_admin)
      oceanview_course = courses(:oceanview_handbook)
      brookside_course = courses(:brookside_handbook)
      canned_course = courses(:canned)

      assert_permit(:preview, user, oceanview_course)
      assert_permit(:preview, user, brookside_course)
      assert_permit(:preview, user, canned_course)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        oceanview_course = courses(:oceanview_handbook)
        brookside_course = courses(:brookside_handbook)
        canned_course = courses(:canned)

        assert_permit(:preview, user, oceanview_course)
        assert_permit(:preview, user, canned_course)
        refute_permit(:preview, user, brookside_course)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      oceanview_course = courses(:oceanview_handbook)
      brookside_course = courses(:brookside_handbook)
      canned_course = courses(:canned)

      refute_permit(:preview, user, oceanview_course)
      refute_permit(:preview, user, canned_course)
      refute_permit(:preview, user, brookside_course)
    end
  end

  describe '#new_question?' do
    test 'when course is deactivated' do
      deactivated_course = Struct.new(:deactivated?).new(true)

      refute_permit(:new_question, nil, deactivated_course)
    end

    test 'when question limit has been reached' do
      refute_permit(:new_question, nil, courses(:with_question_limit_reached))
    end

    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:new_question, user, Course.new)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when course is canned' do
          user = users(role)
          canned_course = courses(:canned)

          refute_permit(:new_question, user, canned_course)
        end

        test 'when course is custom' do
          user = users(role)
          custom_course = courses(:oceanview_handbook)

          assert_permit(:new_question, user, custom_course)
        end
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:new_question, user, Course.new)
    end
  end

  describe '#edit_question?' do
    test 'when course is deactivated' do
      deactivated_course = Struct.new(:deactivated?).new(true)

      refute_permit(:edit_question, nil, deactivated_course)
    end

    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:edit_question, user, Course.new)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when course is canned' do
          user = users(role)
          canned_course = courses(:canned)

          refute_permit(:edit_question, user, canned_course)
        end

        test 'when course is custom' do
          user = users(role)
          custom_course = courses(:oceanview_handbook)

          assert_permit(:edit_question, user, custom_course)
        end
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:edit_question, user, Course.new)
    end
  end

  describe '#destroy_question' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:destroy_question, user, Course.new)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        another_user = users(:another_account_owner)

        assert_permit(:destroy_question, user, user.account_custom_courses.first)
        refute_permit(:destroy_question, user, another_user.account_custom_courses.first)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:destroy_question, user, Course.new)
    end
  end

  describe '#download_supplements?' do
    test 'as a super admin' do
      user = users(:super_admin)
      course = courses(:oceanview_handbook)
      canned_course = courses(:canned)

      assert_permit(:download_supplements, user, course)
      assert_permit(:download_supplements, user, canned_course)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        user = users(role)
        course = courses(:oceanview_handbook)
        canned_course = courses(:canned)
        other_course = courses(:brookside_handbook)

        assert_permit(:download_supplements, user, course)
        assert_permit(:download_supplements, user, canned_course)
        refute_permit(:download_supplements, user, other_course)
      end
    end
  end

  describe '#destroy_supplement?' do
    test 'as a super admin' do
      user = users(:super_admin)
      course = courses(:oceanview_handbook)
      canned_course = courses(:canned)

      assert_permit(:destroy_supplement, user, course)
      assert_permit(:destroy_supplement, user, canned_course)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        course = courses(:oceanview_handbook)
        canned_course = courses(:canned)
        other_course = courses(:brookside_handbook)

        assert_permit(:destroy_supplement, user, course)
        refute_permit(:destroy_supplement, user, canned_course)
        refute_permit(:destroy_supplement, user, other_course)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      course = courses(:oceanview_handbook)

      refute_permit(:destroy_supplement, user, course)
    end
  end

  describe '#assign?' do
    test 'when course is deactivated' do
      deactivated_course = Struct.new(:deactivated?).new(true)

      refute_permit(:assign, nil, deactivated_course)
    end

    test 'when course has no questions' do
      user = nil
      course = build(:course, questions: [])

      refute_permit(:assign, user, course)
    end

    test 'when account has no employee records' do
      context = PolicyContext.new(users(:super_admin), build(:account))
      course = build(:course, :with_question)

      refute_permit(:assign, context, course)
    end

    test 'as a super admin' do
      context = PolicyContext.new(users(:super_admin), accounts(:oceanview_dental))
      course = build(:course, :with_question)

      assert_permit(:assign, context, course)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        course = courses(:oceanview_handbook)
        another_course = courses(:brookside_handbook)
        canned_course = courses(:canned)

        assert_permit(:assign, user, course)
        assert_permit(:assign, user, canned_course)
        refute_permit(:assign, user, another_course)
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:assign, user, Course.new)
    end
  end

  describe '#deactivate?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:deactivate, user, Course.new)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)

        assert_permit(:deactivate, user, courses(:oceanview_handbook))
        refute_permit(:deactivate, user, courses(:brookside_handbook))
        refute_permit(:deactivate, user, courses(:canned))
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:deactivate, user, Course.new)
    end
  end

  describe '#reactivate?' do
    describe 'as a super admin' do
      test 'when not deactivated' do
        user = users(:super_admin)
        course = build(:course)

        refute_permit(:reactivate, user, course)
      end

      test 'when deactivated' do
        user = users(:super_admin)
        course = build(:course, :deactivated)

        assert_permit(:reactivate, user, course)
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when course does not belong to user account' do
          refute_permit(:reactivate, users(role), courses(:brookside_handbook))
        end

        test 'when course belongs to user account and is not deactivated' do
          user = users(role)
          course = build(:course, account: user.account)

          refute_permit(:reactivate, user, course)
        end

        test 'when course belongs to user account and is deactivated' do
          user = users(role)
          course = build(:course, :deactivated, account: user.account)

          assert_permit(:reactivate, user, course)
        end
      end
    end

    test 'as an employee' do
      user = users(:employee)

      refute_permit(:reactivate, user, Course.new)
    end
  end

  describe '#permitted_attributes' do
    test 'when NOT super_admin' do
      user = users(:account_owner)
      course = build(:course)

      subject = CoursePolicy.new(user, course)

      refute_includes subject.permitted_attributes, :is_canned
      refute_includes subject.permitted_attributes, :states
    end

    test 'as a super_admin' do
      user = users(:super_admin)
      course = build(:course)

      subject = CoursePolicy.new(user, course)

      assert_includes subject.permitted_attributes, :is_canned
      assert_includes subject.permitted_attributes, :states
    end
  end
end
