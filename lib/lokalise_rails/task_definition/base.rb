# frozen_string_literal: true

require 'ruby-lokalise-api'
require "pathname"

module LokaliseRails
  module TaskDefinition
    class Base
      class << self
        attr_writer :api_client

        def api_client
          @api_client ||= ::Lokalise.client LokaliseRails.api_token
        end

        def check_required_opts
          if LokaliseRails.project_id.nil? || LokaliseRails.project_id.empty?
            return [
              false, 'Project ID is not set! Aborting...'
            ]
          end
          if LokaliseRails.api_token.nil? || LokaliseRails.api_token.empty?
            return [
              false, 'Lokalise API token is not set! Aborting...'
            ]
          end
          [true, '']
        end

        private

        def has_proper_ext?(name)
          LokaliseRails.file_ext_regexp.match? name
        end

        def subdir_and_filename_for(entry)
          Pathname.new(entry).split
        #  entry.include?('/') ? entry.split('/') : ['', entry]
        end
      end
    end
  end
end
