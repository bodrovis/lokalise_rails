# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'yaml'

module FileManager
  extend self

  def locales_root
    Pathname(LokaliseRails::GlobalConfig.locales_path.to_s)
  end

  def mkdir_locales
    FileUtils.mkdir_p(locales_root)
  end

  def locales_entries
    Dir[locales_root.join('**', '*').to_s]
  end

  def rm_translation_files
    FileUtils.rm_rf(locales_entries)
  end

  def count_translations
    locales_entries.count { |path| File.file?(path) }
  end

  def add_translation_files!(with_ru: false, additional: nil)
    write_file(locales_root.join('nested', 'en.yml')) { |f| f.write(en_data) }

    write_file(locales_root.join('ru.yml')) { |f| f.write(ru_data) } if with_ru

    return unless additional

    additional.times do |i|
      data = {'en' => {"key_#{i}" => "value #{i}"}}
      write_file(locales_root.join("en_#{i}.yml")) { |f| f.write(data.to_yaml) }
    end
  end

  def add_config!(custom_text = '')
    data = <<~RUBY
      # frozen_string_literal: true

      if defined?(LokaliseRails) && defined?(LokaliseRails::GlobalConfig)
        LokaliseRails::GlobalConfig.config do |c|
          c.api_token  = ENV["LOKALISE_API_TOKEN"]
          c.project_id = ENV["LOKALISE_PROJECT_ID"]
    RUBY

    data += custom_text
    data += <<~RUBY
        end

        LokaliseRails::GlobalConfig.for_project(:dummy_project) do |c|
          c.project_id = ENV["LOKALISE_PROJECT_ID"]
        end
      end
    RUBY

    write_file(Rails.root.join('config', 'lokalise_rails.rb')) { |f| f.write(data) }
  end

  def remove_config
    FileUtils.remove_file(config_file) if File.file?(config_file)
  end

  def config_file
    Rails.root.join('config', 'lokalise_rails.rb')
  end

  private

  def write_file(path, &block)
    path = Pathname(path)
    FileUtils.mkdir_p(path.dirname)
    File.open(path.to_s, 'w:UTF-8', &block)
  end

  def en_data
    <<~DATA
      en:
        my_key: "My value"
        nested:
          key: "Value 2"
    DATA
  end

  def ru_data
    <<~DATA
      ru_RU:
        my_key: "Моё значение"
        nested:
          key: "Значение 2"
    DATA
  end
end
