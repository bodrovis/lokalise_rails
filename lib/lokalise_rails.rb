# frozen_string_literal: true

require 'zeitwerk'
require 'lokalise_manager'

loader = Zeitwerk::Loader.for_gem
loader.ignore "#{__dir__}/lokalise_rails/railtie.rb"
loader.ignore "#{__dir__}/generators/templates/lokalise_rails_config.rb"
loader.ignore "#{__dir__}/generators/lokalise_rails/install_generator.rb"
loader.setup

# Main LokaliseRails module
module LokaliseRails
end

require_relative 'lokalise_rails/railtie' if defined?(Rails)
