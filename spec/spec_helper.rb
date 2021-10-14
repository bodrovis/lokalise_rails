# frozen_string_literal: true

require 'dotenv/load'
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/generators/templates/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require_relative '../spec/dummy/config/environment'
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy"

RSpec.configure do |config|
  config.include FileManager
  config.include RakeUtils
  config.include SpecAddons
end

# rubocop:disable Style/MixinUsage
include FileManager
# rubocop:enable Style/MixinUsage

add_config!
Rails.application.load_tasks
