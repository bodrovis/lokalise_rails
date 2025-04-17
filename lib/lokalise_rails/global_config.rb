# frozen_string_literal: true

module LokaliseRails
  # Extends `LokaliseManager::GlobalConfig` to provide a global configuration
  # specific to the LokaliseRails gem in a Rails application.
  class GlobalConfig < LokaliseManager::GlobalConfig
    class << self
      attr_writer :disable_export_task

      # Returns whether the export task should be disabled.
      #
      # Defaults to `false` if not explicitly set.
      #
      # @return [Boolean] `true` if the export task is disabled, otherwise `false`.
      def disable_export_task
        @disable_export_task.nil? ? false : @disable_export_task
      end

      # Returns the path to the directory where translation files are stored.
      #
      # Defaults to `config/locales` under the Rails application root if not explicitly set.
      #
      # @return [String] Absolute path to the locales directory.
      def locales_path
        @locales_path || "#{LokaliseRails::Utils.root}/config/locales"
      end
    end
  end
end
