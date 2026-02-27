# frozen_string_literal: true

if defined?(LokaliseRails) && defined?(LokaliseRails::GlobalConfig)
  LokaliseRails::GlobalConfig.config do |c|
    c.api_token  = ENV["LOKALISE_API_TOKEN"]
    c.project_id = ENV["LOKALISE_PROJECT_ID"]
  end

  LokaliseRails::GlobalConfig.for_project(:dummy_project) do |c|
    c.project_id = ENV["LOKALISE_PROJECT_ID"]
  end
end
