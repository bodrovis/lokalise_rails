# frozen_string_literal: true

module LokaliseRails
  # Global configuration, based on LokaliseManager config
  class GlobalConfig < LokaliseManager::GlobalConfig
    class << self
      def locales_path
        @locales_path || "#{LokaliseRails::Utils.root}/config/locales"
      end
    end
  end
end
