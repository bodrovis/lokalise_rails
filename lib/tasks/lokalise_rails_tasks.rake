# frozen_string_literal: true

require 'rake'
require 'lokalise_rails'
require "#{LokaliseRails::Utils.root}/config/lokalise_rails"

namespace :lokalise_rails do
  task :import do
    importer = LokaliseManager.importer({}, LokaliseRails::GlobalConfig)
    importer.import!
  rescue StandardError => e
    abort e.inspect
  end

  task :export do
    exporter = LokaliseManager.exporter({}, LokaliseRails::GlobalConfig)
    exporter.export!
  rescue StandardError => e
    abort e.inspect
  end
end
