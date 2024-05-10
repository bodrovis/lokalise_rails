# frozen_string_literal: true

require 'pathname'

module LokaliseRails
  # Util methods
  module Utils
    class << self
      # Retrieves the root directory of the current project.
      # It attempts to find the Rails root directory if Rails is loaded.
      # If Rails is not present, it defaults to the current working directory of the process.
      #
      # @return [Pathname] A Pathname object pointing to the root directory of the project.
      def root
        # Uses Pathname to create a robust path object from the rails_root or the current working directory.
        Pathname.new(rails_root || Dir.getwd)
      end

      # Attempts to determine the root directory of a Rails
      # project by checking the presence of Rails and its root method.
      # If Rails is older and does not have the root method, it falls back to the RAILS_ROOT constant if defined.
      #
      # @return [String, nil] the path to the root directory if Rails is defined, or nil if it cannot be determined.
      def rails_root
        # First, check if Rails.root is defined and return its path if available.
        return ::Rails.root.to_s if defined?(::Rails.root) && ::Rails.root
        # Fallback to the RAILS_ROOT constant from older Rails versions.
        return RAILS_ROOT.to_s if defined?(RAILS_ROOT)

        # Returns nil if none of the above are defined, indicating Rails is not present.
        nil
      end
    end
  end
end
