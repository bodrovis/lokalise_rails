# frozen_string_literal: true

require 'rails/generators'

module LokaliseRails
  # Generators for LokaliseRails
  module Generators
    # Installs LokaliseRails config
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Creates a LokaliseRails config file.'

      def copy_config
        template 'lokalise_rails_config.rb', "#{Rails.root}/config/lokalise_rails.rb"
      end
    end
  end
end
