# frozen_string_literal: true

require 'lokalise_rails/task_definition/base'
require 'lokalise_rails/task_definition/importer'
require 'lokalise_rails/task_definition/exporter'

module LokaliseRails
  class << self
    attr_accessor :api_token, :project_id
    attr_writer :import_opts, :import_safe_mode, :export_opts, :locales_path,
                :file_ext_regexp, :skip_file_export

    # Main interface to provide configuration options for rake tasks
    def config
      yield self
    end

    # Full path to directory with translation files
    def locales_path
      @locales_path || "#{Rails.root}/config/locales"
    end

    # Regular expression used to select translation files with proper extensions
    def file_ext_regexp
      @file_ext_regexp || /\.ya?ml\z/i
    end

    # Options for import rake task
    def import_opts
      @import_opts || {
        format: 'yaml',
        placeholder_format: :icu,
        yaml_include_root: true,
        original_filenames: true,
        directory_prefix: '',
        indentation: '2sp'
      }
    end

    # Options for export rake task
    def export_opts
      @export_opts || {}
    end

    # Enables safe mode for import. When enabled, will check whether the target folder is empty or not
    def import_safe_mode
      @import_safe_mode.nil? ? false : @import_safe_mode
    end

    # Additional file skip criteria to apply when performing export
    def skip_file_export
      @skip_file_export || ->(_) { false }
    end
  end
end

require 'lokalise_rails/railtie' if defined?(Rails)
