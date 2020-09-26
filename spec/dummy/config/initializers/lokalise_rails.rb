# frozen_string_literal: true

require 'lokalise_rails'

# These are mandatory options that you must set before running rake tasks:
LokaliseRails.api_token = ENV['LOKALISE_API_TOKEN']
LokaliseRails.project_id = ENV['LOKALISE_PROJECT_ID']

# Import options have the following defaults:
# @import_opts = {
#   format: 'yaml',
#   placeholder_format: :icu,
#   yaml_include_root: true,
#   original_filenames: true,
#   directory_prefix: '',
#   indentation: '2sp'
# }

# Safe mode is disabled by default:
# @import_safe_mode = false

# Provide a custom path to the directory with your translation files:
# class LokaliseRails
#   class << self
#     def locales_path
#       "#{Rails.root}/config/locales"
#     end
#   end
# end
