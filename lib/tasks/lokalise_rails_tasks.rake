# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'

require LokaliseRails::Utils.root.join('config', 'lokalise_rails.rb').to_s

# Rake tasks for syncing translation files between a Rails project and Lokalise.
namespace :lokalise_rails do
  prefix_for = lambda do |project_name|
    name = project_name&.to_s&.strip
    name && !name.empty? ? "[#{name}] " : ''
  end

  run_task = lambda do |kind, opts, project_name: nil|
    prefix = prefix_for.call(project_name)

    if kind == :import && LokaliseRails::GlobalConfig.disable_import_task
      $stdout.puts("#{prefix}Import task is disabled.")
      return
    end

    if kind == :export && LokaliseRails::GlobalConfig.disable_export_task
      $stdout.puts("#{prefix}Export task is disabled.")
      return
    end

    case kind
    when :import
      LokaliseManager.importer(opts, LokaliseRails::GlobalConfig).import!
    when :export
      LokaliseManager.exporter(opts, LokaliseRails::GlobalConfig).export!
    else
      raise ArgumentError, "Unknown task kind: #{kind.inspect}"
    end
  rescue StandardError => e
    warn e.full_message if ENV['LOKALISE_RAILS_TRACE'] == 'true'
    abort "#{prefix}#{kind.to_s.capitalize} failed: #{e.message}"
  end

  ##########################################################################
  # DEFAULT (GLOBAL) TASKS
  ##########################################################################
  desc 'Import translations from Lokalise into the Rails project'
  task :import do
    run_task.call(:import, LokaliseRails::GlobalConfig.project_opts(:default))
  end

  desc 'Export translations from the Rails project to Lokalise'
  task :export do
    run_task.call(:export, LokaliseRails::GlobalConfig.project_opts(:default))
  end

  ##########################################################################
  # SCOPED TASKS (PER PROJECT)
  ##########################################################################
  LokaliseRails::GlobalConfig.projects.each_key do |project_name|
    namespace project_name do
      desc "Import translations from Lokalise (#{project_name})"
      task :import do
        run_task.call(:import, LokaliseRails::GlobalConfig.project_opts(project_name), project_name: project_name)
      end

      desc "Export translations to Lokalise (#{project_name})"
      task :export do
        run_task.call(:export, LokaliseRails::GlobalConfig.project_opts(project_name), project_name: project_name)
      end
    end
  end

  if ENV['LOKALISE_RAILS_TEST'] == 'true'
    task :__test_unknown_kind do
      run_task.call(:wat, {}, project_name: nil)
    end
  end
end
