# frozen_string_literal: true

require 'ruby-lokalise-api'

class LokaliseRails
  module TaskDefinition
    class Base
      class << self
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
      end
    end
  end
end
