# frozen_string_literal: true

if defined?(LokaliseRails::GlobalConfig)
  LokaliseRails::GlobalConfig.config do |c|
    # These are mandatory options that you must set before running rake tasks:
    # c.api_token = ENV['LOKALISE_API_TOKEN']
    # c.project_id = ENV['LOKALISE_PROJECT_ID']

    # Provide a custom path to the directory with your translation files:
    # c.locales_path = "#{Rails.root}/config/locales"

    # Provide a Lokalise project branch to use:
    # c.branch = ''

    # Provide request timeouts for the Lokalise API client:
    # c.additional_client_opts = {open_timeout: nil, timeout: nil}

    # Provide maximum number of retries for file exporting:
    # c.max_retries_export = 5

    # Provide maximum number of retries for file importing:
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

    # Provide additional file exclusion criteria for exports (by default, any file with the proper extension will be exported)
    # c.skip_file_export = ->(file) { file.split[1].to_s.include?('fr') }

    # Set the options below if you would like to work with format other than YAML
    ## Regular expression to use when choosing the files to extract from the downloaded archive and upload to Lokalise
    ## c.file_ext_regexp = /\.ya?ml\z/i

    ## Load translations data and make sure they are valid:
    ## c.translations_loader = ->(raw_data) { YAML.safe_load raw_data }

    ## Convert translations data to a proper format:
    ## c.translations_converter = ->(raw_data) { YAML.dump(raw_data).gsub(/\\\\n/, '\n') }

    ## Infer language ISO code for the translation file:
    ## c.lang_iso_inferer = ->(data, _path) { YAML.safe_load(data)&.keys&.first }

    ## Pre-process translations before exporting to Lokalise:
    ## c.export_preprocessor = ->(raw_data, _path) { raw_data }

    ## Adjust filenames before exporting to Lokalise:
    ## c.export_filename_generator = ->(_full_path, relative_path) { relative_path }

    ## Disable the export rake task:
    ## c.disable_export_task = false

    ## Disable the import rake task:
    ## c.disable_import_task = false
  end

  # To sync with a second Lokalise project, register a named config.
  # This auto-generates lokalise_rails:<name>:import and lokalise_rails:<name>:export tasks.
  # Settings not set here fall back to the GlobalConfig block above.
  #
  # LokaliseRails::GlobalConfig.for_project(:mobile) do |c|
  #   c.project_id  = ENV['LOKALISE_MOBILE_PROJECT_ID']
  #   c.locales_path = "#{Rails.root}/config/locales/mobile"
  # end
end
