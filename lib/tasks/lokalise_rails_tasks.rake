# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
# Loads the configuration settings from the lokalise_rails configuration file within the Rails project.
require "#{LokaliseRails::Utils.root}/config/lokalise_rails"

# Namespace for Rake tasks related to the LokaliseRails gem.
# These tasks facilitate the synchronization of localization files between the Rails project and the Lokalise platform.
namespace :lokalise_rails do
  # Imports translation files from Lokalise and integrates them into the current Rails project.
  # This task utilizes the LokaliseManager to handle the import process according to the configuration specified
  # in the GlobalConfig class.
  desc 'Imports translation files from Lokalise to the current Rails project'
  task :import do
    importer = LokaliseManager.importer({}, LokaliseRails::GlobalConfig)
    importer.import!
  rescue StandardError => e
    # Aborts the task and prints the error message.
    # Ensures that any exceptions raised during import are handled gracefully.
    abort "Import failed: #{e.message}"
  end

  # Exports translation files from the current Rails project to Lokalise.
  # Similar to the import task, it leverages the LokaliseManager and uses the GlobalConfig for configuration settings.
  desc 'Exports translation files from the current Rails project to Lokalise'
  task :export do
    exporter = LokaliseManager.exporter({}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    # Aborts the task and prints the error message. Provides clear feedback on why the export failed.
    abort "Export failed: #{e.message}"
  end
end
