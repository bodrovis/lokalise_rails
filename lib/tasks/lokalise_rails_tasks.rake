# frozen_string_literal: true

require 'rake'
require "#{Rails.root}/config/lokalise_rails"

namespace :lokalise_rails do
  task :import do
    msg = LokaliseRails::TaskDefinition::Importer.import!
    $stdout.print msg
  end
end
