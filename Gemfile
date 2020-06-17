source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails'
gem 'bootstrap', '~> 4.5.0'
gem 'jquery-rails'
gem "actionview", ">= 5.2.4.2"
gem 'pg'
gem 'puma', '~> 3.12.2'
gem 'sass-rails' #, '~> 5.0'
gem 'simple_form', '~> 5.0'
#gem 'bootstrap-sass' #, '~> 3.4.1'
gem 'devise', '~> 4.5'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 2.1'
gem 'jbuilder', '~> 2.5'
gem 'jquery-ui-rails'
gem 'rails-jquery-autocomplete'
gem 'autocomplete_rails'
gem 'rb-readline'
gem 'hirb'
gem 'link_thumbnailer'
gem 'wicked'
gem 'pagy'
gem 'onebox'
gem 'jquery-turbolinks'
gem 'rails-i18n'
gem 'htmlbeautifier'
gem 'prettier'
gem 'popper_js'
gem 'react-rails'

gem 'spring', '>= 2.1.0'

gem 'jwt'
gem "pundit"
gem 'devise-jwt', '~> 0.6.0'
gem 'rack-cors', require: 'rack/cors'
gem 'simple_token_authentication', '~> 1.0'

gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap4-datetime-picker-rails'
gem 'bootstrap-datepicker-rails'
gem 'chosen-rails'

gem "sanitize", ">= 5.2.1"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
end


source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
  # add the line below
  gem 'rails-assets-chosen'
end

group :development do
  gem "capistrano", "~> 3.11", require: false
end

group :development do
#  gem "guard", ">= 2.2.2", :require => false
#  gem "guard-livereload",  :require => false
#  gem "rack-livereload"
  gem "i18n-tasks"
  gem "rb-fsevent",        :require => false
end
