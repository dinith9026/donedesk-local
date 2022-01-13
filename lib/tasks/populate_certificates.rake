namespace :donedesk do
  namespace :oneoff do
    desc 'Populate certificates'
    task populate_certificates: :environment do
      puts 'POPULATING...'
      puts '------------'

      Exam.all.each do |exam|
        if exam.passed?
          exam.assignment.create_certificate!(exam.created_at)
          puts "CREATED certificate for passed exam: #{exam.assignment.employee_record_full_name} / #{exam.course_title}"
        else
          puts "SKIPPING certificate for failed exam: #{exam.assignment.employee_record_full_name} / #{exam.course_title}"
        end
      end

      puts 'Done.'
    end
  end
end
