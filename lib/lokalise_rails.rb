# frozen_string_literal: true

require 'zeitwerk'
require 'lokalise_manager'

require 'lokalise_rails/utils'
require 'lokalise_rails/global_config'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Main LokaliseRails module
module LokaliseRails
end

require 'lokalise_rails/railtie' if defined?(Rails)
