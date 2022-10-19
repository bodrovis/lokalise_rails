# frozen_string_literal: true

require 'pathname'

module LokaliseRails
  # Util methods
  module Utils
    class << self
      # Current project root
      def root
        Pathname.new(rails_root || Dir.getwd)
      end

      # Tries to get Rails root if Rails is defined
      def rails_root
        return ::Rails.root.to_s if defined?(::Rails.root) && ::Rails.root
        return RAILS_ROOT.to_s if defined?(RAILS_ROOT)

        nil
      end
    end
  end
end
