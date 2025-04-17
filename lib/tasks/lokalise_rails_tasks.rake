# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require File.join(LokaliseRails::Utils.root, 'config', 'lokalise_rails')

# Rake tasks for syncing translation files between a Rails project and Lokalise.
namespace :lokalise_rails do
  ##########################################################################
  # IMPORT
  ##########################################################################
  desc 'Import translations from Lokalise into the Rails project'
  task :import do
    importer = LokaliseManager.importer({}, LokaliseRails::GlobalConfig)
    importer.import!
  rescue StandardError => e
    abort "Import failed: #{e.message}"
  end

  ##########################################################################
  # EXPORT
  ##########################################################################
  desc 'Export translations from the Rails project to Lokalise'
  task :export do
    if LokaliseRails::GlobalConfig.disable_export_task
      $stdout.puts 'Export task is disabled.'
      exit 0
    end

    exporter = LokaliseManager.exporter({}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    abort "Export failed: #{e.message}"
  end
end
