module RAI
  module Common
    def self.included(klass)

      def version
        ::RailsAppInitializer::VERSION
      end

      def config
        ::RailsAppInitializer.config
      end

      def config_file_path
        default_path('rails_app_initializer_config.rb')
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

      def gemfile_path
        default_path('Gemfile')
      end

      def use_turbolinks?
        config.use_turbolinks
      end

      def database_yml_path
        default_path('config/database.yml')
      end

      def default_path(filename)
        Rails.root.join(filename)
      end

      def generate_secret_key
        require 'securerandom'
        SecureRandom.hex(64)
      end

      def update_file_with_content(relative_path, content, removable_relative_path=nil)
        if removable_relative_path.present?
          file = default_path(removable_relative_path)
          File.delete(file) if File.exist?(file)
        end
        File.open(default_path(relative_path), 'w') { |f| f.write content }
      end

    end
  end
end