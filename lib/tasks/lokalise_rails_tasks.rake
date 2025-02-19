# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require "#{LokaliseRails::Utils.root}/config/lokalise_rails" # Loads configuration settings for LokaliseRails

# Rake tasks for syncing translation files between a Rails project and Lokalise.
namespace :lokalise_rails do
  # Imports translations from Lokalise into the current Rails project.
  #
  # Uses LokaliseManager to fetch translations based on the configuration
  # defined in `LokaliseRails::GlobalConfig`.
  #
  # @raise [StandardError] Prints an error message and aborts if the import fails.
  desc 'Import translations from Lokalise into the Rails project'
  task :import do
    importer = LokaliseManager.importer({}, LokaliseRails::GlobalConfig)
    importer.import!
  rescue StandardError => e
    abort "Import failed: #{e.message}"
  end

  # Exports translations from the Rails project to Lokalise.
  #
  # Uses LokaliseManager to push localization files based on the configuration
  # in `LokaliseRails::GlobalConfig`.
  #
  # @raise [StandardError] Prints an error message and aborts if the export fails.
  desc 'Export translations from the Rails project to Lokalise'
  task :export do
    exporter = LokaliseManager.exporter({}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    abort "Export failed: #{e.message}"
  end
end
