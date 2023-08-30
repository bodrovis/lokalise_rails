# frozen_string_literal: true

require 'dotenv/load'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start 'rails' do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end
  
  add_filter 'spec/'
  add_filter '.github/'
  add_filter 'lib/generators/templates/'
end

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

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
