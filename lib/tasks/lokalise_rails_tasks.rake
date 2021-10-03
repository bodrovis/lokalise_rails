# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require "#{LokaliseRails::Utils.root}/config/lokalise_rails"

namespace :lokalise_rails do
  task :import do
    LokaliseRails::TaskDefinition::Importer.new.import!
  rescue StandardError => e
    abort e.inspect
  end

  task :export do
    LokaliseRails::TaskDefinition::Exporter.new.export!
  rescue StandardError => e
    abort e.inspect
  end
end
