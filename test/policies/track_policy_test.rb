require 'test_helper'

class TrackPolicyTest < PolicyTest
  describe '#index?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as a #{role}" do
        assert_permit(:index, users(role), Track)
      end
    end

    test "as an employee" do
      refute_permit(:index, users(:employee), Track)
    end
  end

  describe '#new?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as a #{role}" do
        assert_permit(:new, users(role), Track)
      end
    end

    test "as an employee" do
      refute_permit(:new, users(:employee), Track)
    end
  end

  describe '#create?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as a #{role}" do
        assert_permit(:create, users(role), Track)
      end
    end

    test "as an employee" do
      refute_permit(:create, users(:employee), Track)
    end
  end

  describe '#show?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        assert_permit(:show, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:show, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:show, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          assert_permit(:show, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:show, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:show, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#edit?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:edit, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:edit, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:edit, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:edit, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:edit, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:edit, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#update?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:update, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:update, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:update, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:update, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:update, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:update, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#assign?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:assign, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:assign, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:assign, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:assign, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:assign, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:assign, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#unassign?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:unassign, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:unassign, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:unassign, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:unassign, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:unassign, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:unassign, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#add_course?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:add_course, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:add_course, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:add_course, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:add_course, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:add_course, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:add_course, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#reorder_courses?' do
    test 'as super_admin' do
      assert_permit(:reorder_courses, users(:super_admin), tracks(:for_oceanview))
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:reorder_courses, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account' do
          assert_permit(:reorder_courses, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:reorder_courses, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#remove_course?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:remove_course, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track only has one course' do
        refute_permit(:remove_course, users(:super_admin), tracks(:with_one_course))
      end

      test 'when track is active' do
        assert_permit(:remove_course, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:remove_course, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:remove_course, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when track only has one course' do
          refute_permit(:remove_course, users(role), tracks(:with_one_course))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:remove_course, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:remove_course, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#destroy?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        assert_permit(:destroy, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:destroy, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:destroy, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          assert_permit(:destroy, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:destroy, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:destroy, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#deactivate?' do
    describe 'as super_admin' do
      test 'when track is deactivated' do
        refute_permit(:deactivate, users(:super_admin), tracks(:for_oceanview_deactivated))
      end

      test 'when track is active' do
        assert_permit(:deactivate, users(:super_admin), tracks(:for_oceanview))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:deactivate, users(role), tracks(:for_brookside))
        end

        test 'when record belongs to their account but is deactivated' do
          refute_permit(:deactivate, users(role), tracks(:for_oceanview_deactivated))
        end

        test 'when record belongs to their account and is active' do
          assert_permit(:deactivate, users(role), tracks(:for_oceanview))
        end
      end
    end

    test "as an employee" do
      refute_permit(:deactivate, users(:employee), tracks(:for_oceanview))
    end
  end

  describe '#reactivate?' do
    describe 'as super_admin' do
      test 'when track is active' do
        refute_permit(:reactivate, users(:super_admin), tracks(:for_oceanview))
      end

      test 'when track is deactivated' do
        assert_permit(:reactivate, users(:super_admin), tracks(:for_oceanview_deactivated))
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when record does not belong to their account' do
          refute_permit(:reactivate, users(role), tracks(:for_brookside_deactivated))
        end

        test 'when record belongs to their account but is active' do
          refute_permit(:reactivate, users(role), tracks(:for_oceanview))
        end

        test 'when record belongs to their account and is deactivated' do
          assert_permit(:reactivate, users(role), tracks(:for_oceanview_deactivated))
        end
      end
    end

    test "as an employee" do
      refute_permit(:reactivate, users(:employee), tracks(:for_oceanview_deactivated))
    end
  end
end
