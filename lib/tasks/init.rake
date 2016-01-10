require 'rubygems'
require 'rake'
require 'fileutils'

dirname = "#{File.dirname(__FILE__).split('/')[0..-2].join('/')}/rails_app_initializer"
require "#{dirname}/modules/common.rb"
Dir["#{dirname}/classes/*.rb"].each { |f| require f }

namespace :rails_app_initializer do

  include RAI::Common

  desc 'It makes configuration file'
  task :install => :environment do
    RAI::ConfigFileManager.new.create_config_file
  end

  desc 'It configures application'
  task :configure do
    begin
      log('-> Start')
      next unless configuration_is_ok?
      update_gemfile
      update_database_yml
      update_environments
      update_application_files
      configure_rspec
      #TODO run rake tasks?
    rescue StandardError => e
      log("===> ERROR! #{e.message}")
      log('Task was not comleted!')
    ensure
      log('-> Finish')
    end
  end

  def config
    RailsAppInitializer.config
  end

  def configuration_is_ok?
    log('Preparing and checking config...')
    manager = RAI::ConfigFileManager.new
    return false if manager.config_file_is_missing?
    require(manager.config_file_path)
    return false if manager.config_data_was_not_reset?
    true
  end

  def update_gemfile
    log('Updating gemfile...')
    RAI::GemfileManager.new.update_gemfile
  end

  def update_database_yml
    log('Updating database.yml...')
    RAI::DatabaseConfigManager.new.update_database_config
  end

  def update_environments
    log('Updating environments...')
    RAI::EnvironmentsManager.new.update_environments
  end

  def update_application_files
    log('Updating assets...')
    assets_manager = RAI::AssetsManager.new
    assets_manager.update_application_view
    assets_manager.update_application_css
    assets_manager.update_application_js
    `git add app/views/layouts/application.haml`
    `git add app/assets/stylesheets/application.scss`
  end

  def configure_rspec
    log('Making rspec files...')
    RAI::RspecTestsManager.new.configure
    `git add spec/*`
  end

end