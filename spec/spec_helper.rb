# frozen_string_literal: true

require 'dotenv/load'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start 'rails' do
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/generators/templates/'
  add_filter 'lib/lokalise_rails/version.rb'
end

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require_relative '../spec/dummy/config/environment'
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy"

RSpec.configure do |config|
  config.include FileManager
  config.include SpecAddons
end

# rubocop:disable Style/MixinUsage
include FileManager
# rubocop:enable Style/MixinUsage

add_config!
Rails.application.load_tasks
