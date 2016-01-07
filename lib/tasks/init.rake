require 'rubygems'
require 'rake'
require 'fileutils'

namespace :rails_app_initializer do

  desc 'It makes configuration file'
  task :install => :environment do
    File.open(config_file_path, 'w') do |f|
      f.write <<-CONTENT
RailsAppInitializer.configure do |config|
  #TODO you should change app_name and email
  config.app_name = 'YourAppName'
  config.email = 'mail@example.com'

  config.use_turbolinks = false

  config.db_username = 'postgres'
  config.db_password = 'resolve'
end
      CONTENT
    end
  end

  desc 'It configures application'
  task :configure do
    next unless config_file_exist?
    require(config_file_path)
    next unless config_data_was_reset?
    update_gemfile
    update_database_yml
    update_environments
    update_application_files
    configure_rspec
    #TODO run rake tasks?
  end

  def config
    RailsAppInitializer.config
  end

  def config_file_exist?
    p 'ERROR! Please run rake rails_app_initializer:install before rails_app_initializer:configure' and return false unless File.exist?(config_file_path)
    true
  end

  def config_file_path
    Rails.root.join('rails_app_initializer_config.rb')
  end

  def config_data_was_reset?
    p 'ERROR! Please change configuration data in rails_app_initializer_config.rb on your own' and
        return false if config.app_name == RailsAppInitializer::Config::DEFAULT_APP_NAME || config.email == RailsAppInitializer::Config::DEFAULT_EMAIL
    true
  end

  def update_gemfile
    File.open(gemfile_path, 'w') do |f|
      turbolinks_gem = turbolinks? ? "gem 'turbolinks'" : ''
      f.write <<-CONTENT
source 'https://rubygems.org'

## base ##
ruby '2.2.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'

## database ##
gem 'pg', '0.18.4'

## functional ##
gem 'devise', '3.5.3'
gem 'enumerize', '1.1.0'
gem 'carrierwave', '0.10.0'
gem 'remotipart', '~> 1.2'

## assets ##
gem 'sprockets'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap-sass'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

gem 'rails_app_initializer', '0.0.0.1'

if RUBY_PLATFORM=~ /mingw32/
  gem 'therubyracer', '0.11.0beta1', :platform => :ruby
else
  gem 'therubyracer', '0.12.1', :platform => :ruby
end

# Use jquery as the JavaScript library
gem 'jquery-rails', '4.0.5'
gem 'jquery-ui-rails', '5.0.5'
gem 'jquery-migrate-rails', '1.2.1'
gem 'jquery-validation-rails', '1.13.1'

## utilities ##
gem 'rmagick', '2.13.2', require: false
gem 'mini_magick', '4.3.6'
gem 'haml', '4.0.7'
gem 'haml-rails', '0.9.0' # for generators
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'net-ssh', '2.7.0'
#{turbolinks_gem}

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-its', '1.2.0'
  gem 'shoulda-matchers', '3.0.1'
  gem 'awesome_print', require: 'ap'
  gem 'spork-rails', '4.0.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'quiet_assets', '1.1.0'
  gem 'letter_opener', '1.4.1'
  gem 'active_reload', '0.6.1', require: false
  gem 'binding_of_caller', '0.7.2'
  gem 'better_errors', '0.7.2'
  gem 'bullet', '4.14.10'
  gem 'rack-mini-profiler', '0.9.7'
  gem 'commands'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 2.15.5'
end

group :test do
  gem 'mocha', '1.1.0'
  gem 'capybara', '2.5.0'
  gem 'factory_girl_rails', '4.5.0'
  gem 'database_cleaner', '1.5.1'
  gem 'faker', '1.6.1'
  gem 'launchy', '2.4.3'
  gem 'selenium-webdriver', '2.48.1'
  gem 'warden', '1.2.4'
  gem 'guard-rspec', '4.6.4'
  gem 'timecop', '0.8.0'
  gem 'enumerize-matchers', '0.0.2'
end

# Use unicorn as the app server
group :production do
  gem 'exception_notification'
  platforms :ruby do # linux
    gem 'unicorn'
  end
end
      CONTENT
    end
  end

  def gemfile_path
    rails_path_to_file('Gemfile')
  end

  def update_database_yml
    File.open(database_yml_path, 'w') do |f|
      app_name = config.app_name.underscore #TODO remove symbols except \s and _
      username = config.db_username
      password = config.db_password
      f.write <<-CONTENT
development:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_development
  pool: 5
  username: #{username}
  password: #{password}
  host: 127.0.0.1

test:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_test
  pool: 5
  username: #{username}
  password: #{password}
  host: 127.0.0.1

production:
  adapter: postgresql
  encoding: unicode
  database: #{app_name}_production
  pool: 5
  username: #{username}
  password: #{password}
  host: 127.0.0.1
      CONTENT
    end
  end

  def database_yml_path
    rails_path_to_file('config/database.yml')
  end

  def update_environments
    File.open(environment_config_path('development'), 'w') do |f|
      f.write <<-CONTENT
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.secret_key_base = '#{generate_secret_key}'

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
      CONTENT
    end
    File.open(environment_config_path('production'), 'w') do |f|
      f.write <<-CONTENT
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.secret_key_base = '#{generate_secret_key}'

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :warn

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
  config.action_mailer.default_url_options = { host: 'http://example.com' } #TODO change it to real URL
  config.action_mailer.asset_host = 'http://example.com' #TODO change it to real URL

  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.sendmail_settings = {
      :location => '/usr/sbin/sendmail',
      :arguments => '-i'
  }

  config.middleware.use Rack::Deflater

  config.middleware.use ExceptionNotification::Rack,
                        email: {
                            email_prefix: '[Error] ',
                            sender_address: '"notifier" <no-reply@example.com>', #TODO change it to real URL
                            exception_recipients: %w{mail@example.com} #TODO change it to real email
                        },
                        ignore_exceptions: ['ActionController::BadRequest'] + ExceptionNotifier.ignored_exceptions,
                        ignore_crawlers: %w{Googlebot bingbot SemrushBot}

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
      CONTENT
    end
    File.open(environment_config_path('test'), 'w') do |f|
      f.write <<-CONTENT
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.secret_key_base = '#{generate_secret_key}'

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static file server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
      CONTENT
    end
  end

  def environment_config_path(env)
    rails_path_to_file("config/environments/#{env}.rb")
  end

  def generate_secret_key
    require 'securerandom'
    SecureRandom.hex(64)
  end

  def update_application_files
    update_application_view
    update_application_css
    update_application_js
  end

  def update_application_view
    old_file = rails_path_to_file('app/views/layouts/application.html.erb')
    File.delete(old_file) if File.exist?(old_file)
    turbolinks_track = config.use_turbolinks ? ", 'data-turbolinks-track' => true" : ''
    File.open(rails_path_to_file('app/views/layouts/application.haml'), 'w') do |f|
      f.write <<-CONTENT
!!!
%html
  %head
    %title #{config.app_name}
    = stylesheet_link_tag    'application', media: 'all'#{turbolinks_track}
    = javascript_include_tag 'application'#{turbolinks_track}
    = csrf_meta_tags
  %body
    = yield
      CONTENT
    end
    `git add app/views/layouts/application.haml`
  end

  def update_application_css
    old_file = rails_path_to_file('app/assets/stylesheets/application.css')
    File.delete(old_file) if File.exist?(old_file)
    File.open(rails_path_to_file('app/assets/stylesheets/application.scss'), 'w') do |f|
      f.write <<-CONTENT
@charset "utf-8";
      CONTENT
    end
    `git add app/assets/stylesheets/application.scss`
  end

  def update_application_js
    turbolinks = turbolinks? ? '//= require turbolinks' : '//'
    File.open(rails_path_to_file('app/assets/javascripts/application.js'), 'w') do |f|
      f.write <<-CONTENT
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.remotipart
#{turbolinks}
// require_tree .
      CONTENT
    end
  end

  def configure_rspec
    create_directory(rails_path_to_file('spec'))
    create_spec_helper
    create_rails_helper
    create_shared_contexts
    create_directory(rails_path_to_file('spec/support'))
    create_support_helpers
    create_support_controller_macros
    create_support_devise
    `git add spec/*`
  end

  def create_spec_helper
    File.open(rails_path_to_file('spec/spec_helper.rb'), 'w') do |f|
      f.write <<-CONTENT
# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
      CONTENT
    end
  end

  def create_rails_helper
    File.open(rails_path_to_file('spec/rails_helper.rb'), 'w') do |f|
      f.write <<-CONTENT
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'factory_girl_rails'
require 'devise'
require 'shoulda/matchers'
require 'rspec/its'
require 'shared_contexts'

ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose a library:
    with.library :active_record
    with.library :active_model
    with.library :action_controller
  end
end

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
  config.include Warden::Test::Helpers
  config.include Helpers, type: :controller

  config.before :suite do
    Warden.test_mode!
  end

  config.after :each do
    Warden.test_reset!
  end

  config.filter_run focus: true
  config.filter_run_excluding slow: true
  config.run_all_when_everything_filtered = true

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "\#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")


  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end
end
      CONTENT
    end
  end

  def create_shared_contexts
    File.open(rails_path_to_file('spec/shared_contexts.rb'), 'w') do |f|
      f.write <<-CONTENT
RSpec.shared_context 'api request authentication helper methods' do
  def sign_in(user)
    login_as(user, scope: :user)
  end

  def sign_out
    logout(:user)
  end
end

RSpec.shared_context 'for unauthorized user' do
  describe 'GET #index' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { get :index }
    end
  end

  describe 'GET #show' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { get :index, id: object }
    end
  end

  describe 'GET #new' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { get :new }
    end
  end

  describe 'POST #create' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { post :create, id: object }
    end
  end

  describe 'GET #edit' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { get :edit, id: object }
    end
  end

  describe 'PATCH #update' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { patch :update, id: object }
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to new_user_session_path' do
      for_unauthorized_expectation { delete :destroy, id: create(:search_request) }
    end
  end
end


RSpec.shared_context 'for authorized user' do

  describe 'GET #index' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation { get :index }
    end
  end

  describe 'GET #show' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation { get :index, id: user_object }
    end
  end

  describe 'GET #new' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation { get :new }
    end
  end

  describe 'POST #create' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation(302) { post :create, id: user_object, "\#{user_object.class.to_s.underscore}" => user_object_params }
    end
  end

  describe 'GET #edit' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation { get :edit, id: user_object }
    end
  end

  describe 'PATCH #update' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation(302) { patch :update, id: user_object, "\#{user_object.class.to_s.underscore}" => user_object_params }
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to new_user_session_path' do
      for_authorized_expectation(302) { delete :destroy, id: user_object }
    end
  end
end
      CONTENT
    end
  end

  def create_support_helpers
    File.open(rails_path_to_file('spec/support/helpers.rb'), 'w') do |f|
      f.write <<-CONTENT
module Helpers

  def for_unauthorized_expectation
    yield
    expect(response).to redirect_to(new_user_session_path)
  end

  def for_authorized_expectation(status=200)
    yield
    expect(response).to have_http_status(status)
  end

end
      CONTENT
    end
  end

  def create_support_devise
    File.open(rails_path_to_file('spec/support/devise_request_spec_helpers.rb'), 'w') do |f|
      f.write <<-CONTENT
module DeviseRequestSpecHelpers

  include Warden::Test::Helpers

  def sign_in(resource_or_scope, resource = nil)
    resource ||= resource_or_scope
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    login_as(resource, scope: scope)
  end

  def sign_out(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    logout(scope)
  end

end
      CONTENT
    end
  end

  def create_support_controller_macros
    File.open(rails_path_to_file('spec/support/controller_macros.rb'), 'w') do |f|
      f.write <<-CONTENT
module ControllerMacros

  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in create(:administrator) # Using factory girl as an example
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = create(:confirmed_user)
      user.confirm
      sign_in user
    end
  end

end
      CONTENT
    end
  end

  def rails_path_to_file(relative_path)
    Rails.root.join(relative_path)
  end

  def create_directory(path)
    FileUtils.mkdir_p(path)
  end

  def turbolinks?
    config.use_turbolinks
  end

end