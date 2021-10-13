# frozen_string_literal: true

require 'lokalise_manager'

require 'lokalise_rails/utils'
require 'lokalise_rails/global_config'

module LokaliseRails
end

require 'lokalise_rails/railtie' if defined?(Rails)
