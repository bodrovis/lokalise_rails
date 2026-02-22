# frozen_string_literal: true

require 'rails/generators'

module LokaliseRails
  module Generators
    # Installs the LokaliseRails configuration file in a Rails application.
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      # Adds a configuration file for LokaliseRails to the Rails application.
      desc 'Creates a config/lokalise_rails.rb file for LokaliseRails.'

      # Copies the configuration template to the application's config directory.
      def copy_config
        template 'lokalise_rails_config.rb', Rails.root.join('config', 'lokalise_rails.rb')
      end
    end
  end
end
