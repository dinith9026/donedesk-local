# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Dir['./lib/done_desk/**/*.rake'].sort.each do |rake_file|
  load rake_file
end

Rails.application.load_tasks
