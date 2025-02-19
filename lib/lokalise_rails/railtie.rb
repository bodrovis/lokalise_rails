# frozen_string_literal: true

module LokaliseRails
  # Extends Rails via Railtie to integrate LokaliseRails functionalities.
  #
  # This Railtie ensures that custom Rake tasks from the LokaliseRails gem
  # are automatically available within a Rails application.
  class Railtie < Rails::Railtie
    # Registers custom Rake tasks for LokaliseRails.
    #
    # This ensures that the tasks are loaded when the Rails application boots
    # and Rake is invoked.
    rake_tasks do
      load 'tasks/lokalise_rails_tasks.rake'
    end
  end
end
