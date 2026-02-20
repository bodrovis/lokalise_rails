# frozen_string_literal: true

if defined?(LokaliseRails) && defined?(LokaliseRails::GlobalConfig)
  LokaliseRails::GlobalConfig.config do |c|
    c.api_token = ENV.fetch('LOKALISE_API_TOKEN', nil)
    c.project_id = ENV.fetch('LOKALISE_PROJECT_ID', nil)
  end

  LokaliseRails::GlobalConfig.for_project(:dummy_project) do |c|
    c.project_id = ENV.fetch('LOKALISE_PROJECT_ID', nil)
  end
end
