namespace :rails_app_initalizer do
  desc 'It makes configuration file'
  task :install => :environment do
    File.open(Rails.root.join('rails_app_initializer_config.rb'), 'w') do
      <<-CONTENT
        RailsAppInitializer.configure do
          config.app_name = 'YourAppName'
          config.email = 'mail@example.com'
          config.use_turbolinks = false
        end
      CONTENT
    end
  end
end