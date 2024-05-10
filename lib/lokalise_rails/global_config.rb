# frozen_string_literal: true

module LokaliseRails
  # Inherits from LokaliseManager::GlobalConfig to provide a global configuration specific to the LokaliseRails gem.
  # This class is primarily used to manage configuration settings that affect how the LokaliseRails gem operates
  # within a Ruby on Rails application, particularly in managing locale paths.
  class GlobalConfig < LokaliseManager::GlobalConfig
    class << self
      # Provides the path to the locales directory where translation files are stored. If not set explicitly,
      # it defaults to the `config/locales` directory within the root of the application using this gem.
      #
      # @return [String] the path to the locales directory
      def locales_path
        # If @locales_path is not set, it defaults to a path under the application's root directory.
        @locales_path || "#{LokaliseRails::Utils.root}/config/locales"
      end
    end
  end
end
