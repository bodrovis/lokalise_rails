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
      # - Falls back to `RAILS_ROOT` for legacy Rails versions.
      # - Returns `nil` when Rails is not available.
      #
      # @return [Pathname, nil] Pathname pointing to the Rails root, or `nil`.
      def rails_root
        if defined?(::Rails) && ::Rails.respond_to?(:root) && (r = ::Rails.root)
          Pathname(r)
        elsif defined?(::RAILS_ROOT)
          Pathname(::RAILS_ROOT)
        end
      end
    end
  end
end
