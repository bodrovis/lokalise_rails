# frozen_string_literal: true

module LokaliseRails
  # Extends `LokaliseManager::GlobalConfig` to provide a global configuration
  # specific to the LokaliseRails gem in a Rails application.
  class GlobalConfig < LokaliseManager::GlobalConfig
    class << self
      attr_writer :disable_export_task, :disable_import_task

      # Returns whether the export task should be disabled.
      #
      # Defaults to `false` if not explicitly set.
      #
      # @return [Boolean] `true` if the export task is disabled, otherwise `false`.
      def disable_export_task
        @disable_export_task.nil? ? false : @disable_export_task
      end

      # Returns whether the import task should be disabled.
      #
      # Defaults to `false` if not explicitly set.
      #
      # @return [Boolean] `true` if the import task is disabled, otherwise `false`.
      def disable_import_task
        @disable_import_task.nil? ? false : @disable_import_task
      end

      # Returns the path to the directory where translation files are stored.
      #
      # Defaults to `config/locales` under the Rails application root if not explicitly set.
      #
      # @return [String] Absolute path to the locales directory.
      def locales_path
        @locales_path || "#{LokaliseRails::Utils.root}/config/locales"
      end

      # Registers a named project config and auto-generates scoped rake tasks
      # (lokalise_rails:<name>:import and lokalise_rails:<name>:export).
      #
      # Settings not explicitly set in the block fall back to GlobalConfig
      # via LokaliseManager's inline override mechanism, so shared options
      # like api_token only need to be set once in the main config block.
      #
      # @param name [Symbol, String] identifier for the project
      # @yield [collector] block to configure project-specific settings
      #
      # @example
      #   LokaliseRails::GlobalConfig.for_project(:mobile) do |c|
      #     c.project_id  = ENV['LOKALISE_MOBILE_PROJECT_ID']
      #     c.locales_path = "#{Rails.root}/config/locales/mobile"
      #   end
      def for_project(name, &block)
        collector = ProjectConfigCollector.new
        block&.call(collector)
        projects[name.to_sym] = collector.to_h
      end

      # Returns the registry of named project configs.
      #
      # @return [Hash{Symbol => Hash}]
      def projects
        @projects ||= {}
      end
    end

    # Collects attribute assignments from a for_project block into a plain hash.
    # The hash is passed as inline overrides to LokaliseManager.importer/exporter,
    # so any attribute not explicitly set falls back to GlobalConfig automatically.
    class ProjectConfigCollector
      def initialize
        @settings = {}
      end

      def to_h
        @settings.dup
      end

      def method_missing(name, *args)
        attr = name.to_s
        if attr.end_with?('=')
          @settings[attr.chomp('=').to_sym] = args.first
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        name.to_s.end_with?('=') || super
      end
    end

    private_constant :ProjectConfigCollector
  end
end
