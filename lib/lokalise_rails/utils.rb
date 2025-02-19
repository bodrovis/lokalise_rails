# frozen_string_literal: true

require 'pathname'

module LokaliseRails
  # Utility methods for LokaliseRails
  module Utils
    class << self
      # Retrieves the root directory of the current project.
      #
      # If Rails is available, it returns `Rails.root`. Otherwise, it defaults
      # to the current working directory.
      #
      # @return [Pathname] Pathname object pointing to the project root.
      def root
        Pathname.new(rails_root || Dir.getwd)
      end

      # Determines the root directory of a Rails project.
      #
      # - Uses `Rails.root` if available.
      # - Falls back to `RAILS_ROOT` for older Rails versions.
      # - Returns `nil` if Rails is not present.
      #
      # @return [String, nil] Path to the root directory or `nil` if not found.
      def rails_root
        return ::Rails.root.to_s if defined?(::Rails.root) && ::Rails.root
        return RAILS_ROOT.to_s if defined?(RAILS_ROOT)

        nil
      end
    end
  end
end
