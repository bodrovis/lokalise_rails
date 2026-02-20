# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require File.join(LokaliseRails::Utils.root, 'config', 'lokalise_rails')

# Rake tasks for syncing translation files between a Rails project and Lokalise.
namespace :lokalise_rails do
  run_import = lambda do |opts, project_name: nil|
    if LokaliseRails::GlobalConfig.disable_import_task
      $stdout.puts 'Import task is disabled.'
      exit 0
    end

    LokaliseManager.importer(opts, LokaliseRails::GlobalConfig).import!
  rescue StandardError => e
    name = project_name&.to_s
    prefix = name && !name.empty? ? "[#{name}] " : ''
    abort "#{prefix}Import failed: #{e.message}"
  end

  run_export = lambda do |opts, project_name: nil|
    if LokaliseRails::GlobalConfig.disable_export_task
      $stdout.puts 'Export task is disabled.'
      exit 0
    end

    LokaliseManager.exporter(opts, LokaliseRails::GlobalConfig).export!
  rescue StandardError => e
    name = project_name&.to_s
    prefix = name && !name.empty? ? "[#{name}] " : ''
    abort "#{prefix}Export failed: #{e.message}"
  end

  ##########################################################################
  # DEFAULT (GLOBAL) TASKS
  ##########################################################################
  desc 'Import translations from Lokalise into the Rails project'
  task :import do
    run_import.call({})
  end

  desc 'Export translations from the Rails project to Lokalise'
  task :export do
    run_export.call({})
  end

  ##########################################################################
  # SCOPED TASKS (PER PROJECT)
  ##########################################################################
  LokaliseRails::GlobalConfig.projects.each do |project_name, project_opts|
    namespace project_name.to_s do
      desc "Import translations from Lokalise (#{project_name})"
      task :import do
        run_import.call(project_opts, project_name: project_name)
      end

      desc "Export translations to Lokalise (#{project_name})"
      task :export do
        run_export.call(project_opts, project_name: project_name)
      end
    end
  end
end
