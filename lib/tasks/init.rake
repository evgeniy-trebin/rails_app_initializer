require 'rubygems'
require 'rake'
require 'fileutils'

dirname = "#{File.dirname(__FILE__).split('/')[0..-2].join('/')}/rails_app_initializer"
require "#{dirname}/modules/common.rb"
require "#{dirname}/classes/config_file_manager.rb"
require "#{dirname}/classes/gemfile_manager.rb"
require "#{dirname}/classes/database_config_manager.rb"
require "#{dirname}/classes/environments_manager.rb"

namespace :rails_app_initializer do

  desc 'It makes configuration file'
  task :install => :environment do
    RAI::ConfigFileManager.new.create_config_file
  end

  desc 'It configures application'
  task :configure do
    next unless configuration_is_ok?
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

  def configuration_is_ok?
    manager = RAI::ConfigFileManager.new
    return false if manager.config_file_is_missing?
    require(manager.config_file_path)
    return false if  manager.config_data_was_not_reset?
    true
  end

  def update_gemfile
    RAI::GemfileManager.new.update_gemfile
  end

  def update_database_yml
    RAI::DatabaseConfigManager.new.update_database_config
  end

  def update_environments
    RAI::EnvironmentsManager.new.update_environments
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