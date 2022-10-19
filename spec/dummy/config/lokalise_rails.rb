# frozen_string_literal: true

LokaliseRails::GlobalConfig.config do |c|
  c.api_token = ENV.fetch('LOKALISE_API_TOKEN', nil)
  c.project_id = ENV.fetch('LOKALISE_PROJECT_ID', nil)
end
