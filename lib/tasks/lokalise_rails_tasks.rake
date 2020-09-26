# frozen_string_literal: true

require 'rake'
require 'ruby-lokalise-api'
require 'zip'
require 'open-uri'
require 'yaml'
require "#{Rails.root}/config/lokalise_rails"

namespace :lokalise_rails do
  task :import do
    msg = LokaliseRails::TaskDefinition::Importer.import!
    $stdout.print msg
  end
end
