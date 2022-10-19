# frozen_string_literal: true

module LokaliseRails
  # Load Rake tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/lokalise_rails_tasks.rake'
    end
  end
end
