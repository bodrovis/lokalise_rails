# frozen_string_literal: true

require 'ruby-lokalise-api'
require 'pathname'

module LokaliseRails
  module TaskDefinition
    class Base
      class << self
        attr_writer :api_client

        def api_client
          @api_client ||= ::Lokalise.client LokaliseRails.api_token
        end

        def opt_errors
          errors = []
          errors << 'Project ID is not set! Aborting...' if LokaliseRails.project_id.nil? || LokaliseRails.project_id.empty?
          errors << 'Lokalise API token is not set! Aborting...' if LokaliseRails.api_token.nil? || LokaliseRails.api_token.empty?
          errors
        end

        private

        def proper_ext?(raw_path)
          path = raw_path.is_a?(Pathname) ? raw_path : Pathname.new(raw_path)
          LokaliseRails.file_ext_regexp.match? path.extname
        end

        def subdir_and_filename_for(entry)
          Pathname.new(entry).split
        end
      end
    end
  end
end
