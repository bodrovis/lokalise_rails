# frozen_string_literal: true

require 'lokalise_rails/task_definition/base'
require 'lokalise_rails/task_definition/importer'
require 'lokalise_rails/railtie' if defined?(Rails)

class LokaliseRails
  @project_id = nil
  @import_opts = {
    format: 'yaml',
    placeholder_format: :icu,
    yaml_include_root: true,
    original_filenames: true,
    directory_prefix: '',
    indentation: '2sp'
  }
  # @export_opts = {
  #
  # }
  @import_safe_mode = false
  @api_token = nil

  class << self
    attr_accessor :import_opts, :import_safe_mode, :api_token, :export_opts,
                  :project_id

    def locales_path
      "#{Rails.root}/config/locales"
    end
  end
end
