namespace :donedesk do
  namespace :oneoff do
    desc 'Migrate course material'
    task migrate_course_material: :environment do
      puts 'MIGRATING...'
      puts '------------'

      Course.all.each do |course|
        bucket = Rails.configuration.donedesk.aws_s3_bucket
        url = "//s3-us-west-2.amazonaws.com/#{bucket}/courses/materials/#{course.id}/#{course.material_file_name}"

        course.update!(material_url: url)
        puts url
      end

      puts 'Done.'
    end
  end
end
