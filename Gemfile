source 'https://rubygems.org'
ruby "#{`cat './.ruby-version'`}".strip

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '5.2.4.4'

gem 'active_model_otp', '~> 2.1.0'
gem 'acts_as_list'
gem 'american_date', '~> 1.1.1'
gem 'attr_bitwise', '~> 0.0.4'
gem "attr_encrypted", "~> 3.1.0"
gem 'aws-sdk', '< 3.0'
gem 'bcrypt', '~> 3.1.7'
gem 'bigdecimal', '1.4.2'
#gem 'bootsnap', '>= 1.1.0', require: false
gem 'clearance', '~> 2.3.0'
gem 'clockwork'
gem 'date_validator', '~> 0.10.0'
gem 'dotenv-rails', '~> 2.7.6'
gem 'email_validator', '~> 2.0.1'
gem 'exception_notification', '~> 4.2'
gem 'intercom', '~> 3.9.5'
gem 'intercom-rails'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'kaminari'
gem 'lograge'
gem 'logstash-event'
gem 'mailgun-ruby', '~> 1.2.0'
gem 'paperclip', '~> 5.3.0'
gem 'pg', '~> 1.2.3'
gem 'puma', '~> 4.0'
gem 'pundit', '~> 2.1.0'
gem 'rails-controller-testing', '~> 1.0.1'
gem 'rqrcode'
gem 'rubyzip'
gem 'sass-rails', '~> 6.0'
gem 'sentry-raven'
gem 'sidekiq'
gem 'slack-notifier', '~> 2.1'
gem 'stripe', '~> 3.4.0'
gem 'storext', '~> 3.1.0'
gem 'tzinfo-data'
gem 'uglifier', '>= 4.2.0'
gem 'rectify'
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf', '~> 2.1.0'
gem 'zip-zip'
gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'byebug'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'lol_dba'
  gem 'pry-plus-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'better_errors'
  gem 'bullet'
  gem 'listen', '~> 3.3.0'
  gem 'method_profiler'
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console'
end

group :test do
  gem 'capybara', '~> 2.18.0'
  gem 'webdrivers', '~> 3.0'
  gem 'database_cleaner', '~> 1.8.5'
  gem 'launchy', '~> 2.5.0'
  gem 'minitest-rails-capybara', '~> 3.0.1'
  gem 'minitest-spec-rails', '~> 5.4.0'
  gem 'mocha', '~> 1.11.2'
  gem 'poltergeist', '~> 1.15.0'
  gem 'selenium-webdriver', '~> 3.3.0'
  gem 'shoulda', '~> 4.0.0'
  gem 'shoulda-matchers', '~> 4.4.0'
  #gem 'stripe-ruby-mock', '~> 2.5.0', require: 'stripe_mock'
  gem 'stripe-ruby-mock', github: 'rebelidealist/stripe-ruby-mock', branch: 'release-2.5'
  gem 'wisper-minitest', require: false
end
