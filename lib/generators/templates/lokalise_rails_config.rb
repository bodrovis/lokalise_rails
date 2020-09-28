# frozen_string_literal: true

require 'lokalise_rails'

LokaliseRails.config do |c|
  # These are mandatory options that you must set before running rake tasks:
  # c.api_token = ENV['LOKALISE_API_TOKEN']
  # c.project_id = ENV['LOKALISE_PROJECT_ID']

  # Import options have the following defaults:
  # c.import_opts = {
  #   format: 'yaml',
  #   placeholder_format: :icu,
  #   yaml_include_root: true,
  #   original_filenames: true,
  #   directory_prefix: '',
  #   indentation: '2sp'
  # }

  # Safe mode for imports is disabled by default:
  # c.import_safe_mode = false

  # Provide a custom path to the directory with your translation files:
  # c.locales_path = "#{Rails.root}/config/locales"

  # Regular expression to use when choosing the files to export from the downloaded archive
  # c.file_ext_regexp = /\.ya?ml/i
end
