# frozen_string_literal: true

require 'pathname'

module LokaliseRails
  # Utility methods for LokaliseRails
  module Utils
    class << self
      # Returns the root directory of the current project.
      #
      # If Rails is available, this returns `Rails.root`.
      # Otherwise, it falls back to the current working directory.
      #
      # @return [Pathname] Pathname pointing to the project root.
      def root
        rails_root || Pathname.pwd
      end

      # Returns the root directory of a Rails application, if present.
      #
      # - Uses `Rails.root` when Rails is loaded.
      # - Returns `nil` when Rails is not available.
      #
      # @return [Pathname, nil] Pathname pointing to the Rails root, or `nil`.
      def rails_root
        ::Rails.root if defined?(::Rails) && ::Rails.respond_to?(:root)
      end

      def require_config!
        config_path = root.join('config', 'lokalise_rails.rb')

        unless config_path.exist?
          abort <<~MSG
            LokaliseRails configuration file was not found at #{config_path}.
            Run `rails generate lokalise_rails:install` first.
          MSG
        end

        require config_path.to_s
      end
    end
  end
end
