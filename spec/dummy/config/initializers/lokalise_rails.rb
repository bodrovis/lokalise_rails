# frozen_string_literal: true

require 'lokalise_rails'

LokaliseRails.api_token = ENV['LOKALISE_API_TOKEN']
LokaliseRails.project_id = ENV['LOKALISE_PROJECT_ID']
# LokaliseRails.opts[:indentation] = '8sp'
