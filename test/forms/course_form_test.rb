require 'test_helper'
require_relative '../models/concerns/common_course_validation_tests'

class CourseFormTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  include CommonCourseValidationTests

  setup do
    @assigned_course = courses(:oceanview_handbook)
    @unassigned_course = courses(:oceanview_unassigned)
    @user = users(:account_manager)
  end

  test '#material_presigned_post' do
    form = CourseForm.new

    result = form.material_presigned_post

    assert_kind_of Aws::S3::PresignedPost, result
    assert_equal '${filename}', result.fields['x-amz-meta-original-filename']
    assert_match(/courses\/materials\/.{36}\/\$\{filename\}/, result.fields["key"])
  end

  test '#supplement_presigned_post' do
    form = CourseForm.new

    result = form.supplement_presigned_post

    assert_kind_of Aws::S3::PresignedPost, result
    assert_match(/courses\/supplements\/.{36}\/\$\{filename\}/, result.fields["key"])
  end

  describe '#material_file_name' do
    test 'when material_s3_key is nil' do
      form = CourseForm.new(material_s3_key: nil)

      assert_equal '', form.material_file_name
    end

    test 'when material_s3_key is not nil' do
      form = CourseForm.new(material_s3_key: 'courses/material/test.pdf')

      assert_equal 'test.pdf', form.material_file_name
    end
  end

  describe 'when creating' do
    test 'when params are all empty' do
      policy = CoursePolicy.new(@user, Course.new)

      form = CourseForm.new({}).with_policy(policy)

      refute form.valid?
      assert_includes form.errors[:title], "can't be blank"
      assert_includes form.errors[:compliance_expiration_in_days], "can't be blank"
      assert_includes form.errors[:max_test_retakes], "can't be blank"
      assert_includes form.errors[:passing_threshold_percentage], "can't be blank"
    end

    test 'when params are all valid' do
      policy = CoursePolicy.new(@user, Course.new)

      form = CourseForm.new(valid_params).with_policy(policy)

      assert form.valid?, "Should not have errors: #{form.errors.full_messages.inspect}"
    end
  end

  test 'with customer course and title is already taken' do
    policy = CoursePolicy.new(@user, Course.new)
    existing_course = courses(:oceanview_handbook)

    form = CourseForm.new(
      title: existing_course.title,
      account_id: existing_course.account_id).with_policy(policy)

    assert form.invalid?
    assert_includes form.errors[:title], 'already taken'
  end

  test 'with canned course and title is already taken' do
    policy = CoursePolicy.new(@user, Course.new)
    existing_course = courses(:canned)

    form = CourseForm.new(
      title: existing_course.title,
      account_id: nil).with_policy(policy)

    assert form.invalid?
    assert_includes form.errors[:title], 'already taken'
  end

  private

  def valid_params
    attributes_for(:course)
  end
end
