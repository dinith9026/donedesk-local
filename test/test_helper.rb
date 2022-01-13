ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'aws-sdk'
require 'capybara/poltergeist'
require 'capybara/rails'
require 'faker'
require 'minitest/mock'
require 'minitest/rails/capybara'
require 'mocha/minitest'
require 'paperclip/matchers'
require 'pry'
require 'shoulda/matchers'
require 'stripe_mock'
require 'database_cleaner'
require 'wisper/minitest/assertions'
require 'done_desk'

raise "Woah, don't kill the company!" unless Rails.env.test?

Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("test/done_desk/unit/test_support/**/*.rb")].each { |f| require f }

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :transaction
I18n.t('ColdFire')

Mocha.configure do |c|
  c.stubbing_non_existent_method = :prevent
  c.stubbing_method_unnecessarily = :prevent
  c.stubbing_non_public_method = :prevent
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper

# https://github.com/thoughtbot/shoulda-matchers/issues/906
Shoulda::Matchers::ActiveModel::AllowValueMatcher.class_eval do
  alias :failure_message_for_should_not :failure_message_when_negated
end

class ActiveSupport::TestCase
  include TestPasswordHelper
  include StripeMockHelper
  include FactoryBot::Syntax::Methods
  include TestSetupHelpers
  extend Paperclip::Shoulda::Matchers
  fixtures :all

  # Workaround to fix specifying line number when running a test
  # https://github.com/metaskills/minitest-spec-rails/issues/77#issuecomment-298093909
  class << self
    alias :test :it
  end
end

class ActionDispatch::IntegrationTest
  include TestPasswordHelper
  include StripeMockHelper

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def self.it_requires_authenticated_user(&block)
    test 'when user is not authenticated' do
      instance_exec(&block)
      assert_redirected_to sign_in_path
    end
  end

  def assert_redirects_with_flash_success(path)
    assert_response :redirect
    assert_redirected_to path
    refute_nil flash[:success], "Expected flash success but got nil"
  end

  def assert_redirects_with_flash_error(path)
    assert_response :redirect
    assert_redirected_to path
    refute_nil flash[:error], "Expected flash error but got nil"
  end

  def assert_redirects_with_flash_warning(path)
    assert_response :redirect
    assert_redirected_to path
    refute_nil flash[:warning], "Expected flash warning but got nil"
  end

  def assert_redirects_with_not_found_error
    assert_response :redirect
    refute_nil flash[:error], "Expected flash error but got nil"
    assert_includes flash[:error], 'not found'
  end

  def assert_redirects_with_not_authorized_error
    assert_response :redirect
    refute_nil flash[:error], "Expected flash error but got nil"
    assert_includes flash[:error], 'not authorized'
  end

  def auth_params_for(user)
    {
      session: {
        email: user.email,
        password: default_password,
      }
    }
  end

  # Runs assert_difference with a number of conditions and varying difference
  # counts.
  #
  # Call as follows:
  #
  # assert_differences([['Model1.count', 2], ['Model2.count', 3]])
  #
  def assert_differences(expression_array, message = nil, &block)
    b = block.send(:binding)
    before = expression_array.map { |expr| eval(expr[0], b) }

    yield

    expression_array.each_with_index do |pair, i|
      e = pair[0]
      difference = pair[1]
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
  end
end

class ActionMailer::TestCase
  include TestPasswordHelper
  include Rails.application.routes.url_helpers
end

class PolicyTest < ActiveSupport::TestCase
  include TestPasswordHelper
  def assert_permit(action, user, record)
    msg = permit_msg('User should be permitted but is NOT permitted', action, user, record)
    assert permit?(action, user, record), msg
  end

  def refute_permit(action, user, record)
    msg = permit_msg('User should NOT be permitted but is permitted', action, user, record)
    refute permit?(action, user, record), msg
  end

  private

  def permit_msg(msg, action, user, record)
    "\nUSER:\n#{user.inspect}\n\nRECORD:\n#{record.inspect}\n\n#{msg} to: #{action.to_s} #{record.class.to_s}"
  end

  def permit?(action, context, record)
    policy_class.new(context, record).public_send("#{action.to_s}?")
  end

  def policy_class
    described_class.to_s.chomp('Test').constantize
  end
end

class CommandTest < ActiveSupport::TestCase
end

class AcceptanceTestCase < Capybara::Rails::TestCase
  include Acceptance::AuthHelpers
  include Acceptance::PageHelpers
  include Acceptance::Asserts
  include TestPasswordHelper
  include StripeMockHelper

  self.use_transactional_tests = false

  Capybara.configure do |config|
    config.asset_host = 'http://localhost:3000/'
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu) }
    )

    Capybara::Selenium::Driver.new app,
      browser: :chrome,
      desired_capabilities: capabilities
  end

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
      js_errors: false,
      phantomjs_logger: '/dev/null',
      phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any']
    })
  end
end

class Minitest::AcceptanceTest < Minitest::Test; end

class Minitest::Test
  include TestPasswordHelper
  extend ActiveSupport::Testing::Declarative

  UNIT_MAXIMUM_TEST_TIME = 0.015
  ACCEPTANCE_MAXIMUM_TEST_TIME = (ENV['ACCEPTANCE_MAXIMUM_TEST_TIME'] || 10).to_f

  def maximum_test_time
    if ActionDispatch::IntegrationTest === self
      ACCEPTANCE_MAXIMUM_TEST_TIME
    elsif AcceptanceTestCase === self
      ACCEPTANCE_MAXIMUM_TEST_TIME
    elsif Minitest::AcceptanceTest
      ACCEPTANCE_MAXIMUM_TEST_TIME
    else
      UNIT_MAXIMUM_TEST_TIME
    end
  end

  def initialize(name = nil)
    @test_name = name
    super(name)
  end

  def before_setup
    super
    @test_begin_time = Time.now
  end

  def after_teardown
    delta = Time.now - @test_begin_time
    assert_operator(delta, :<=, maximum_test_time, "#{@test_name} took #{delta} seconds to run, but the maximum allowable time is #{maximum_test_time} seconds")
    super
  end
end
