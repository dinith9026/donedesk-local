require 'active_record/fixtures'
require_relative '../../test/support/test_password_helper'

namespace :donedesk do
  namespace :db do
    desc 'Populate database with test data from fixtures'
    task populate: :environment do
      puts 'LOADING TEST DATA...'
      puts '--------------------'

      fixtures_dir = File.join(Rails.root, '/test/fixtures')
      skip_fixtures = ['documents', 'library_documents']
      load_fixtures = [
        'accounts',
        'plans',
        'users',
        'offices',
        'employee_records',
        'courses',
        'assignments',
        'questions',
        'document_types',
        'document_groups',
        'tracks',
        'assigned_tracks',
      ]

      puts "Skipping #{skip_fixtures.join(', ')}"

      puts "Loading #{load_fixtures.join(', ')}..."
      ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, load_fixtures)

      puts 'Done.'
    end

    desc 'Drop, create, migrate, seed and populate from fixtures'
    task repopulate: [:environment, 'db:drop', 'db:create', 'db:migrate', 'db:seed', 'donedesk:db:populate']
  end
end
