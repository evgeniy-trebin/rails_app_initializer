module RAI
  class ConfigFileManager

    include Common

    def create_config_file
      p 'Config file is already exists!' and return true if config_file_exist?
      File.open(config_file_path, 'w') do |f|
        f.write code_for_config_file
      end
    end

    def config_file_is_missing?
      p 'ERROR! Please run rake rails_app_initializer:install before rails_app_initializer:configure' and return true unless config_file_exist?
      false
    end

    def config_data_was_not_reset?
      p 'ERROR! Please change configuration data in rails_app_initializer_config.rb on your own' and return true unless config_data_was_reset?
      false
    end

    private

    def code_for_config_file
      <<-CONTENT
RailsAppInitializer.configure do |config|
  #TODO you should change app_name and email
  config.app_name = '#{default_app_name}'
  config.email = '#{default_email}'

  config.use_turbolinks = false

  config.db_username = 'postgres'
  config.db_password = 'resolve'
end
      CONTENT
    end

  end
end