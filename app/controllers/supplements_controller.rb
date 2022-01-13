class SupplementsController < ApplicationController
  before_action :skip_authorization, only: [:destroy]

  def index
    course = current_account.find_course!(params[:id])
    authorize course, :download_supplements?

    bucket  = donedesk_config.aws_s3_bucket
    signer  = Aws::S3::Presigner.new(client: s3)

    files = []
    tmp_folder = "/tmp/#{SecureRandom.uuid}"
    Dir.mkdir(tmp_folder)

    course.supplements.each do |supplement|
      url = signer.presigned_url(
        :get_object,
        bucket: bucket,
        key: supplement
      )

      filename = File.basename(supplement)
      file = "#{tmp_folder}/#{filename}"

      # object = bucket.object(supplement)
      # object.get(response_target: file)

      require 'open-uri'
      open(file, 'wb') do |f|
        f << open(url).read
      end

      files << file
    end

    path_to_zip = "#{tmp_folder}/supplements-#{course.id}.zip"

    require 'zip'

    Zip::File.open(path_to_zip, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        zipfile.add(File.basename(file), file)
      end
    end

    send_file path_to_zip
  end

  def destroy
    course = current_account.courses.find_by('? = ANY (supplements)', params[:s3_key])

    if course
      authorize course, :destroy_supplement?

      s3.delete_object({
        bucket: donedesk_config.aws_s3_bucket,
        key: params[:s3_key]
      })

      course.supplements.delete(params[:s3_key])
      course.save!
    end

    head :no_content
  end

  private

  def s3
    creds   = donedesk_config.aws_credentials
    region  = donedesk_config.aws_region

    Aws::S3::Client.new(region: region, credentials: creds)
  end

  def donedesk_config
    @donedesk_config ||= Rails.configuration.donedesk
  end
end
