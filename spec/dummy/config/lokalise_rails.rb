# frozen_string_literal: true

LokaliseRails::GlobalConfig.config do |c|
  c.api_token = ENV['LOKALISE_API_TOKEN']
  c.project_id = ENV['LOKALISE_PROJECT_ID']
end
