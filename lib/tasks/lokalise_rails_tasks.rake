# frozen_string_literal: true

require 'rake'
require 'ruby-lokalise-api'
require 'zip'
require 'open-uri'
require 'yaml'

namespace :lokalise_rails do
  task import: :environment do
    #$stdout.print("Project ID is not set! Aborting...") unless LokaliseRails.project_id
  #  $stdout.print("Lokalise API token is not set! Aborting...") unless LokaliseRails.api_token

    msg = LokaliseRails::Importer.import!
    $stdout.print msg
  end
end
