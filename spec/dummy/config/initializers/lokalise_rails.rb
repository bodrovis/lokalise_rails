# frozen_string_literal: true

require 'lokalise_rails'

puts ENV['token']
LokaliseRails.lokalise_token = 'PROVIDE_YOUR_API_TOKEN_HERE'
# LokaliseRails.opts[:indentation] = '8sp'
