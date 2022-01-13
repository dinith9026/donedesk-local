namespace :donedesk do
  desc 'Download all documents for an account'
  task :download_account_documents, [:account_id] => :environment do |task, args|
    puts 'DOWNLOADING...'
    puts '------------'

    account_id = args[:account_id]
    account = Account.find(account_id)

    ts = Time.now.strftime("%Y%m%d%H%M%S").to_s
    zip_file = "#{Rails.root}/tmp/donedesk-employee-documents-#{ts}.zip"

    Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |zip|
      account.documents.each_with_index do |d, index|
        filename = "#{d.employee_record.last_comma_first.parameterize}-#{index}-#{d.file.original_filename}"
        path_to_file = "tmp/#{filename}"
        d.file.copy_to_local_file(:original, path_to_file)
        zip.add(filename, path_to_file)
      end
    end

    # Put on S3
    donedesk_config = Rails.configuration.donedesk

    creds   = donedesk_config.aws_credentials
    region  = donedesk_config.aws_region
    bucket  = donedesk_config.aws_s3_bucket
    key     = File.basename(zip_file)

    s3_client   = Aws::S3::Client.new(region: region, credentials: creds)
    s3_signer   = Aws::S3::Presigner.new(client: s3_client)
    s3_resource = Aws::S3::Resource.new(credentials: creds, region: region)

    obj = s3_resource.bucket(bucket).object(key)
    obj.upload_file(zip_file)

    url = s3_signer.presigned_url(
      :get_object,
      bucket: bucket,
      key: key,
      response_content_disposition: "attachment; filename=\"#{key}\""
    )

    File.delete(zip_file)

    puts url
  end
end
