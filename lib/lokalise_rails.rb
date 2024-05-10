# frozen_string_literal: true

require 'zeitwerk'
require 'lokalise_manager'

# Configure Zeitwerk loader specific for gem environments. This loader is set up to ignore certain files
# that should not be autoloaded, such as Rails-specific files or templates which are not part of the main load path.
loader = Zeitwerk::Loader.for_gem
loader.ignore "#{__dir__}/lokalise_rails/railtie.rb" # Ignore the Railtie in non-Rails environments
loader.ignore "#{__dir__}/generators/templates/lokalise_rails_config.rb"  # Ignore the generator templates
loader.ignore "#{__dir__}/generators/lokalise_rails/install_generator.rb" # Ignore installation generator scripts
loader.setup

# Main module for the LokaliseRails gem. This module serves as the namespace for all components
# related to the LokaliseRails integration. It provides a structured way to manage translations
# through the Lokalise platform within Ruby on Rails applications.
module LokaliseRails
end

# Require the Railtie only if Rails is defined to integrate with Rails without manual configuration.
require_relative 'lokalise_rails/railtie' if defined?(Rails)
