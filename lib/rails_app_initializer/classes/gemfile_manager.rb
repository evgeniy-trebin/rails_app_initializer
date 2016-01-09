module RAI
  class GemfileManager

    include Common

    def update_gemfile
      File.open(gemfile_path, 'w') do |f|
        f.write code_for_gemfile
      end
    end

    def code_for_gemfile
      turbolinks_gem = use_turbolinks? ? "gem 'turbolinks'" : ''
      <<-CONTENT
source 'https://rubygems.org'

## base ##
ruby '2.2.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'

## database ##
gem 'pg', '0.18.4'

## functional ##
gem 'devise', '3.5.3'
gem 'enumerize', '1.1.0'
gem 'carrierwave', '0.10.0'
gem 'remotipart', '~> 1.2'

## assets ##
gem 'sprockets'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap-sass'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

gem 'rails_app_initializer', '#{version}'

if RUBY_PLATFORM=~ /mingw32/
  gem 'therubyracer', '0.11.0beta1', :platform => :ruby
else
  gem 'therubyracer', '0.12.1', :platform => :ruby
end

# Use jquery as the JavaScript library
gem 'jquery-rails', '4.0.5'
gem 'jquery-ui-rails', '5.0.5'
gem 'jquery-migrate-rails', '1.2.1'
gem 'jquery-validation-rails', '1.13.1'

## utilities ##
gem 'rmagick', '2.13.2', require: false
gem 'mini_magick', '4.3.6'
gem 'haml', '4.0.7'
gem 'haml-rails', '0.9.0' # for generators
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'net-ssh', '2.7.0'
#{turbolinks_gem}

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-its', '1.2.0'
  gem 'shoulda-matchers', '3.0.1'
  gem 'awesome_print', require: 'ap'
  gem 'spork-rails', '4.0.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'quiet_assets', '1.1.0'
  gem 'letter_opener', '1.4.1'
  gem 'active_reload', '0.6.1', require: false
  gem 'binding_of_caller', '0.7.2'
  gem 'better_errors', '0.7.2'
  gem 'bullet', '4.14.10'
  gem 'rack-mini-profiler', '0.9.7'
  gem 'commands'

  # Use Capistrano for deployment
  gem 'capistrano', '~> 2.15.5'
end

group :test do
  gem 'mocha', '1.1.0'
  gem 'capybara', '2.5.0'
  gem 'factory_girl_rails', '4.5.0'
  gem 'database_cleaner', '1.5.1'
  gem 'faker', '1.6.1'
  gem 'launchy', '2.4.3'
  gem 'selenium-webdriver', '2.48.1'
  gem 'warden', '1.2.4'
  gem 'guard-rspec', '4.6.4'
  gem 'timecop', '0.8.0'
  gem 'enumerize-matchers', '0.0.2'
end

# Use unicorn as the app server
group :production do
  gem 'exception_notification'
  platforms :ruby do # linux
    gem 'unicorn'
  end
end
      CONTENT
    end

  end
end