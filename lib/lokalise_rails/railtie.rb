# frozen_string_literal: true

module LokaliseRails
  # The Railtie class in Rails is used to extend Rails' functionality within an application, or in this case,
  # a gem. This Railtie is specifically used to add custom Rake tasks from the
  # LokaliseRails gem into the Rails application.
  #
  # It leverages Rails' Railtie architecture to ensure the Rake
  # tasks are loaded when the application boots up and Rake is invoked.
  class Railtie < Rails::Railtie
    # Register Rake tasks that are defined within this gem. This block is called by Rails during the initialization
    # process and ensures that all Rake tasks specific to LokaliseRails are available to the application.
    rake_tasks do
      # Loads the Rake tasks from a file located relative to this file. Ensure this file exists and contains
      # valid Rake task definitions specifically tailored for Lokalise integration.
      load 'tasks/lokalise_rails_tasks.rake'
    end
  end
end
