module RAI
  module Common
    def self.included(klass)
      def config
        ::RailsAppInitializer.config
      end

      def config_file_path
        Rails.root.join('rails_app_initializer_config.rb')
      end

      def config_file_exist?
        File.exist?(config_file_path)
      end

      def config_data_was_reset?
        config.app_name != default_app_name && config.email != default_email
      end

      def default_app_name
        ::RailsAppInitializer::Config::DEFAULT_APP_NAME
      end

      def default_email
        ::RailsAppInitializer::Config::DEFAULT_EMAIL
      end
    end
  end
end