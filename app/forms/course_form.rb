class CourseForm < ApplicationForm
  attribute :account_id, String
  attribute :title, String
  attribute :code, String
  attribute :description, String
  attribute :compliance_expiration_in_days, Integer
  attribute :days_due_within, Integer
  attribute :max_test_retakes, Integer
  attribute :passing_threshold_percentage, Integer
  attribute :material_s3_key, String
  attribute :is_canned, Boolean, default: false
  attribute :certificate_type, Integer
  attribute :states, Array
  attribute :supplements, Array, default: []

  include CommonCourseValidations

  validate :title_is_unique_for_account

  def material_presigned_post
    presigned_post({
      key: "courses/materials/#{SecureRandom.uuid}/${filename}",
      success_action_status: '201',
      metadata: { 'original-filename' => '${filename}' },
      allow_any: ['Content-Type'],
    })
  end

  def supplement_presigned_post
    presigned_post({
      key: "courses/supplements/#{SecureRandom.uuid}/${filename}",
      success_action_status: '201',
      allow_any: ['content-type'],
    })
  end

  def detailed_supplements
    s3 = Aws::S3::Client.new(
      region: donedesk_config.aws_region,
      credentials: donedesk_config.aws_credentials
    )
    bucket = Aws::S3::Bucket.new(donedesk_config.aws_s3_bucket, client: s3)

    @detailed_supplements ||= supplements.map do |supplement|
      object = bucket.object(supplement)

      {
        name: File.basename(supplement),
        size: object.content_length,
        type: object.content_type,
        s3_key: supplement
      }
    end
  end

  def material_file_name
    File.basename(material_s3_key.to_s)
  end

  def is_canned?
    account_id.nil?
  end

  private

  def donedesk_config
    @donedesk_config ||= Rails.configuration.donedesk
  end

  def presigned_post(options)
    creds   = donedesk_config.aws_credentials
    region  = donedesk_config.aws_region
    bucket  = donedesk_config.aws_s3_bucket

    Aws::S3::PresignedPost.new(creds, region, bucket, options)
  end

  def title_is_unique_for_account
    if account_courses_with_title.where.not(id: id).any?
      errors.add(:title, 'already taken')
    end
  end

  def account_courses_with_title
    Course.where(title: title, account_id: account_id)
  end
end
