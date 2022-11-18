# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require "#{LokaliseRails::Utils.root}/config/lokalise_rails"

namespace :lokalise_rails do
  desc 'Imports translation files from Lokalise to the current Rails project'
  task :import do
    importer = LokaliseManager.importer({}, LokaliseRails::GlobalConfig)
    importer.import!
  rescue StandardError => e
    abort e.inspect
  end

  desc 'Exports translation files from the current Rails project to Lokalise'
  task :export do
    exporter = LokaliseManager.exporter({}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    abort e.inspect
  end
end
