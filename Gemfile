# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

ruby_version = Gem::Version.new(RUBY_VERSION)

tz_platforms =
  if ruby_version < Gem::Version.new('3.1')
    %i[mingw mswin x64_mingw jruby]
  else
    %i[windows jruby]
  end

group :test do
  gem 'dotenv', '~> 3.0'
  gem 'rails', '~> 8.1'
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.6'
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-performance', '~> 1.5'
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 3.0'
  gem 'simplecov', '~> 0.22'
  gem 'tzinfo-data', platforms: tz_platforms
  gem 'webmock', '~> 3.14'
end
