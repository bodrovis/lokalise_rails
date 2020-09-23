# frozen_string_literal: true

class LokaliseRails
  @opts = {
    format: 'yaml',
    placeholder_format: :icu,
    yaml_include_root: true,
    original_filenames: true,
    directory_prefix: '',
    indentation: '2sp'
  }
  @path = "#{Rails.root}/config/locales"
  @safe_mode = false

  class << self
    attr_accessor :opts, :path, :safe_mode
  end
end
