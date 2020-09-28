# frozen_string_literal: true

require 'lokalise_rails/task_definition/base'
require 'lokalise_rails/task_definition/importer'

class LokaliseRails
  class << self
    attr_accessor :api_token, :project_id
    attr_writer :import_opts, :import_safe_mode, :export_opts, :locales_path,
                :file_ext_regexp

    def config
      yield self
    end

    def locales_path
      @locales_path || "#{Rails.root}/config/locales"
    end

    def file_ext_regexp
      @file_ext_regexp || /\.ya?ml/i
    end

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

    def import_safe_mode
      @import_safe_mode.nil? ? false : @import_safe_mode
    end
  end
end

require 'lokalise_rails/railtie' if defined?(Rails)
