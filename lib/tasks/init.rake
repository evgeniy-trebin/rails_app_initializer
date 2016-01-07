require 'rubygems'
require 'rake'

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
end
      CONTENT
    end
  end

  desc 'It configures application'
  task :configure do
    p 'ERROR! Please run rake rails_app_initializer:install before rails_app_initializer:configure' and next unless File.exist?(config_file_path)
    #TODO обновить гемфайл
    #TODO обновить database.yml
    #TODO обновить environments
    #TODO обновить application js scss haml
    #TODO сконфигурить Rspec
  end

  def config_file_path
    Rails.root.join('rails_app_initializer_config.rb')
  end

end
