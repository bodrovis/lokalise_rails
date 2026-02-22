# frozen_string_literal: true

if defined?(LokaliseRails::GlobalConfig)
  LokaliseRails::GlobalConfig.config do |c|
    # These are mandatory options that you must set before running rake tasks:
    # c.api_token = ENV['LOKALISE_API_TOKEN']

    # If you have a single Lokalise project, you can keep using the global project_id:
    # c.project_id = ENV['LOKALISE_PROJECT_ID']

    # Provide a custom path to the directory with your translation files:
    # c.locales_path = "#{Rails.root}/config/locales"

    # Provide a Lokalise project branch to use:
    # c.branch = ''

    # Provide request timeouts for the Lokalise API client:
    # c.additional_client_opts = { open_timeout: nil, timeout: nil }

    # Provide maximum number of retries for file exporting/importing:
    # c.max_retries_export = 5
    # c.max_retries_import = 5

    # Import options have the following defaults:
    # c.import_opts = {
    #   format: 'ruby_yaml',
    #   placeholder_format: :icu,
    #   yaml_include_root: true,
    #   original_filenames: true,
    #   directory_prefix: '',
    #   indentation: '2sp'
    # }

    # Safe mode for imports is disabled by default:
    # c.import_safe_mode = false

    # Run imports asynchronously
    # c.import_async = false

    # Additional export options (only filename, contents, and lang_iso params are provided by default)
    # c.export_opts = {}

    # Provide additional file exclusion criteria for exports:
    # c.skip_file_export = ->(file) { file.split[1].to_s.include?('fr') }

    # Advanced customization (non-YAML, custom loaders, etc.) — see README.
  end

  # Default project overrides (optional).
  # Use this if you prefer keeping per-project settings separate from the global setters.
  #
  # LokaliseRails::GlobalConfig.for_default_project do |c|
  #   c.project_id   = ENV['LOKALISE_PROJECT_ID']
  #   c.locales_path = "#{Rails.root}/config/locales"
  # end

  # To sync with additional Lokalise projects, register named configs.
  # This auto-generates:
  #   lokalise_rails:<name>:import
  #   lokalise_rails:<name>:export
  #
  # Settings not set here fall back to GlobalConfig above.
  #
  # LokaliseRails::GlobalConfig.for_project(:mobile) do |c|
  #   c.project_id   = ENV['LOKALISE_MOBILE_PROJECT_ID']
  #   c.locales_path = "#{Rails.root}/config/locales/mobile"
  # end
end
