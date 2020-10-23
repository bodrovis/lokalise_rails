# frozen_string_literal: true

require 'lokalise_rails'

LokaliseRails.config do |c|
  # These are mandatory options that you must set before running rake tasks:
  # c.api_token = ENV['LOKALISE_API_TOKEN']
  # c.project_id = ENV['LOKALISE_PROJECT_ID']

  # Provide a custom path to the directory with your translation files:
  # c.locales_path = "#{Rails.root}/config/locales"

  # Provide a Lokalise project branch to use:
  # c.branch = 'master'

  # Provide request timeouts for the Lokalise API client:
  # c.timeouts = {open_timeout: nil, timeout: nil}

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

  # Additional export options (only filename, contents, and lang_iso params are provided by default)
  # c.export_opts = {}

  # Provide additional file exclusion criteria for exports (by default, any file with the proper extension will be exported)
  # c.skip_file_export = ->(file) { file.split[1].to_s.include?('fr') }

  # Regular expression to use when choosing the files to extract from the downloaded archive and upload to Lokalise
  # c.file_ext_regexp = /\.ya?ml\z/i
end
