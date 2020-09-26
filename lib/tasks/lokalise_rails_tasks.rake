# frozen_string_literal: true

require 'rake'
require 'ruby-lokalise-api'
require 'zip'
require 'open-uri'
require 'yaml'

namespace :lokalise_rails do
  task import: :environment do
    msg = LokaliseRails::TaskDefinition::Importer.import!
    $stdout.print msg
  end
end
