# frozen_string_literal: true

require 'set'

module LokaliseRails
  # Extends `LokaliseManager::GlobalConfig` to provide a global configuration
  # specific to the LokaliseRails gem in a Rails application.
  class GlobalConfig < LokaliseManager::GlobalConfig
    # Manager-supported config keys (for inline overrides)
    MANAGER_CONFIG_KEYS = LokaliseManager::TaskDefinitions::Base::CONFIG_KEYS.to_set.freeze

    class << self
      attr_writer :disable_export_task, :disable_import_task

      def disable_export_task
        !@disable_export_task.nil? && @disable_export_task
      end

      def disable_import_task
        !@disable_import_task.nil? && @disable_import_task
      end

      def locales_path
        (@locales_path || LokaliseRails::Utils.root.join('config', 'locales')).to_s
      end

      # Default inline overrides (stored separately to avoid breaking existing global setters)
      def default_project
        @default_project ||= {}
      end

      # Configure default inline overrides using the same DSL as for_project.
      def for_default_project(&block)
        collector = build_collector
        block&.call(collector)
        default_project.merge!(collector.to_h)
        default_project
      end

      # Returns inline overrides for a named project (or :default).
      def project_opts(name = :default)
        key = normalize_project_key(name)
        return default_project.dup if key == :default

        projects.fetch(key, {}).dup
      end

      # Registers a named project config.
      #
      # @param name [Symbol, String]
      # @yield [collector]
      def for_project(name, &block)
        key = normalize_project_key(name)
        raise ArgumentError, 'Project name can\'t be blank or :default' if key == :default

        collector = build_collector
        block&.call(collector)
        projects[key] = collector.to_h
      end

      def projects
        @projects ||= {}
      end

      private

      def build_collector
        ProjectConfigCollector.new(MANAGER_CONFIG_KEYS)
      end

      def normalize_project_key(name)
        return :default if name.nil?

        str = name.to_s.strip
        return :default if str.empty?

        str.to_sym
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

        raise ArgumentError, "Expected 1 argument for #{method}, got #{args.length}" unless args.length == 1

        key = method.chomp('=').to_sym
        unless @allowed_keys.include?(key)
          allowed = @allowed_keys.to_a.sort
          raise ArgumentError,
                "Unknown config key for for_project: #{key}. Allowed: #{allowed.join(', ')}"
        end

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
