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
  gem 'tzinfo-data', platforms: tz_platforms
  gem 'webmock', '~> 3.14'
end
