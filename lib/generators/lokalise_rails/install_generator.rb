# frozen_string_literal: true

require 'rails/generators'

module LokaliseRails
  module Generators
    # Generator that sets up the LokaliseRails configuration in a Rails application.
    # It copies a predefined configuration template into the appropriate directory within the Rails application,
    # making it easier for users to configure and use LokaliseRails.
    class InstallGenerator < Rails::Generators::Base
      # Sets the directory containing the template files relative to this file's location.
      source_root File.expand_path('../templates', __dir__)

      # Description of the generator's purpose, which is displayed in the Rails generators list.
      desc 'Creates a LokaliseRails config file in your Rails application.'

      # The primary method of this generator, responsible for copying the LokaliseRails configuration template
      # from the gem to the Rails application's config directory. This is where users can customize
      # their Lokalise settings.
      def copy_config
        # Copies the configuration template to the Rails application's config directory.
        template 'lokalise_rails_config.rb', "#{Rails.root}/config/lokalise_rails.rb"
      end
    end
  end
end
