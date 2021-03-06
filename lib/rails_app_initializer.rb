require 'rails_app_initializer/version'

load "#{File.dirname(__FILE__)}/tasks/init.rake"

class RailsAppInitializer

  class Config

    DEFAULT_APP_NAME = 'YourAppName'
    DEFAULT_EMAIL = 'mail@example.com'

    attr_accessor :app_name, :use_turbolinks, :email, :db_username, :db_password, :show_messages

    def initialize
      set_defaults
      yield self if block_given?
    end

    def set_defaults
      @app_name = DEFAULT_APP_NAME
      @email = DEFAULT_EMAIL
      @use_turbolinks = false
      @db_username = 'postgres'
      @db_password = 'resolve'
      @show_messages = true
    end
  end

  attr_reader :configuration

  def self.configure(&block)
    @configuration = Config.new(&block)
  end

  def self.config
    @configuration||= Config.new
  end

end