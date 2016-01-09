module RAI
  class DatabaseConfigManager

    include Common

    def update_database_config
      File.open(database_yml_path, 'w') do |f|
        f.write code_for_database_config
      end
    end

    private

    def code_for_database_config
      app_name = config.app_name.underscore #TODO remove symbols except \s and _
      username = config.db_username
      password = config.db_password
      <<-CONTENT
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
end