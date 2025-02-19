# frozen_string_literal: true

require 'zeitwerk'
require 'lokalise_manager'

# Configure Zeitwerk for managing gem autoloading.
loader = Zeitwerk::Loader.for_gem

# Ignore files that should not be autoloaded.
loader.ignore "#{__dir__}/lokalise_rails/railtie.rb" # Exclude Railtie when not in a Rails app
loader.ignore "#{__dir__}/generators/templates/lokalise_rails_config.rb" # Ignore generator templates
loader.ignore "#{__dir__}/generators/lokalise_rails/install_generator.rb" # Ignore installation generator

loader.setup

# Main module for LokaliseRails.
#
# Serves as the namespace for all components of the LokaliseRails gem,
# providing tools for managing translations in Ruby on Rails applications.
module LokaliseRails
end

# Load Railtie if running within a Rails application.
require_relative 'lokalise_rails/railtie' if defined?(Rails)
