source 'https://rubygems.org'

ruby '3.2.8'
gem 'bootsnap', require: false
gem 'bulma-rails', '~> 0.9.4'
gem 'devise'
gem 'importmap-rails'
gem 'jbuilder'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.3'
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.4'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
end

group :development do
  gem 'htmlbeautifier', '~> 1.3.0'
  gem 'irb', '1.10.0'
  gem 'rubocop', '~> 1.50', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec'
  gem 'ruby-lsp', '~> 0.24.0', require: false # 最新の安定版
  gem 'ruby-lsp-rails', '~> 0.4.6', require: false # Rails用の拡張機能
  gem 'web-console', '4.2.0'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'guard'
  gem 'guard-minitest'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

group :production do
  gem 'pg', '1.3.5'
end
