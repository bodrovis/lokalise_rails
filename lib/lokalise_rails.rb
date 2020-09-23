# frozen_string_literal: true

require 'lokalise_rails/railtie' if defined?(Rails)

class LokaliseRails
  @opts = {
    format: 'yaml',
    placeholder_format: :icu,
    yaml_include_root: true,
    original_filenames: true,
    directory_prefix: '',
    indentation: '2sp'
  }
  @safe_mode = false
  @lokalise_token = nil

  class << self
    attr_accessor :opts, :safe_mode, :lokalise_token

    def loc_path
      "#{Rails.root}/config/locales"
    end
  end
end
