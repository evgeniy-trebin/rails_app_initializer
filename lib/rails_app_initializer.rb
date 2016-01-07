require 'rails_app_initializer/version'
require 'rails'

load "#{File.dirname(__FILE__)}/tasks/init.rake"

class RailsAppInitializer

  class Config

    attr_accessor :app_name, :use_turbolinks, :email

    def initialize
      set_defaults
      yield self if block_given?
    end

    def set_defaults
      @app_name = 'YourAppName'
      @email = 'mail@example.com'
      @use_turbolinks = false
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