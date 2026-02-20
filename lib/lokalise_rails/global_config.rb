# frozen_string_literal: true

module LokaliseRails
  # Extends `LokaliseManager::GlobalConfig` to provide a global configuration
  # specific to the LokaliseRails gem in a Rails application.
  class GlobalConfig < LokaliseManager::GlobalConfig
    # Manager-supported config keys (for inline overrides)
    MANAGER_CONFIG_KEYS = LokaliseManager::TaskDefinitions::Base::CONFIG_KEYS.freeze

    class << self
      attr_writer :disable_export_task, :disable_import_task

      def disable_export_task
        @disable_export_task.nil? ? false : @disable_export_task
      end

      def disable_import_task
        @disable_import_task.nil? ? false : @disable_import_task
      end

      def locales_path
        @locales_path || "#{LokaliseRails::Utils.root}/config/locales"
      end

      # Registers a named project config.
      #
      # @param name [Symbol, String]
      # @yield [collector]
      def for_project(name, &block)
        key = name.to_sym
        collector = ProjectConfigCollector.new(MANAGER_CONFIG_KEYS)
        block&.call(collector)
        projects[key] = collector.to_h
      end

      def projects
        @projects ||= {}
      end
    end

    # Collects attribute assignments from a for_project block into a plain hash.
    class ProjectConfigCollector
      def initialize(allowed_keys)
        @allowed_keys = allowed_keys
        @settings = {}
      end

      def to_h
        @settings.dup
      end

      def method_missing(name, *args)
        method = name.to_s
        return super unless method.end_with?('=')

        key = method.chomp('=').to_sym
        raise ArgumentError, "Unknown config key for for_project: #{key}" unless @allowed_keys.include?(key)

        @settings[key] = args.first
      end

      def respond_to_missing?(name, include_private = false)
        method = name.to_s
        return super unless method.end_with?('=')

        key = method.chomp('=').to_sym
        @allowed_keys.include?(key) || super
      end
    end

    private_constant :ProjectConfigCollector
  end
end
