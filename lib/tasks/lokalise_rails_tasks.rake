# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require "#{LokaliseRails::Utils.root}/config/lokalise_rails"

namespace :lokalise_rails do
  task :import do
    importer = LokaliseManager::TaskDefinitions::Importer.new({}, LokaliseRails::GlobalConfig)
    importer.import!
  rescue StandardError => e
    abort e.inspect
  end

  task :export do
    exporter = LokaliseManager::TaskDefinitions::Exporter.new({}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    abort e.inspect
  end
end
