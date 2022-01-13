require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:skip_acceptance) do |t|
    t.description = 'Runs all tests in test folder EXCEPT acceptance tests'
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb'].exclude(
      'test/acceptance/**/*_test.rb'
    )
    t.verbose = false
    t.warning = false
  end
end
