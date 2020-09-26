require 'ruby-lokalise-api'
require 'open-uri'

class LokaliseRails
  module TaskDefinition
    class Base
      class << self
        def check_required_opts
          return [false, "Project ID is not set! Aborting..."] unless LokaliseRails.project_id
          return [false, "Lokalise API token is not set! Aborting..."] unless LokaliseRails.api_token

          [true, '']
        end
      end
    end
  end
end
