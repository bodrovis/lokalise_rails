# frozen_string_literal: true

require 'rake'
require "#{Rails.root}/config/lokalise_rails"

namespace :lokalise_rails do
  task :import do
    LokaliseRails::TaskDefinition::Importer.import!
  end

  task :export do
    LokaliseRails::TaskDefinition::Exporter.export!
  end
end
