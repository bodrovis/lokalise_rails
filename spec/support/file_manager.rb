# frozen_string_literal: true

require 'fileutils'

module FileManager
  extend self

  def mkdir_locales
    return if File.directory?(LokaliseRails::GlobalConfig.locales_path)

    FileUtils.mkdir_p(LokaliseRails::GlobalConfig.locales_path)
  end

  def rm_translation_files
    FileUtils.rm_rf locales_dir
  end

  def locales_dir
    Dir["#{LokaliseRails::GlobalConfig.locales_path}/**/*"]
  end

  def count_translations
    locales_dir.count { |file| File.file?(file) }
  end

  def add_translation_files!(with_ru: false, additional: nil)
    FileUtils.mkdir_p "#{Rails.root}/config/locales/nested"
    open_and_write('config/locales/nested/en.yml') { |f| f.write en_data }

    return unless with_ru

    open_and_write('config/locales/ru.yml') { |f| f.write ru_data }

    return unless additional

    additional.times do |i|
      data = {'en' => {"key_#{i}" => "value #{i}"}}

      open_and_write("config/locales/en_#{i}.yml") { |f| f.write data.to_yaml }
    end
  end

  def add_config!(custom_text = '')
    data = <<~DATA
      # frozen_string_literal: true

      if defined?(LokaliseRails) && defined?(LokaliseRails::GlobalConfig)
        LokaliseRails::GlobalConfig.config do |c|
          c.api_token = ENV.fetch('LOKALISE_API_TOKEN', nil)
          c.project_id = ENV.fetch('LOKALISE_PROJECT_ID', nil)
    DATA

    data += custom_text
    data += "  end\n\n"
    data += "  LokaliseRails::GlobalConfig.for_project(:dummy_project) do |c|\n"
    data += "    c.project_id = ENV.fetch('LOKALISE_PROJECT_ID', nil)\n"
    data += "  end\n"
    data += "end\n"
    open_and_write('config/lokalise_rails.rb') { |f| f.write data }
  end

  def open_and_write(rel_path, &block)
    return unless block

    File.open("#{Rails.root}/#{rel_path}", 'w:UTF-8', &block)
  end

  def remove_config
    FileUtils.remove_file config_file if File.file?(config_file)
  end

  def config_file
    "#{Rails.root}/config/lokalise_rails.rb"
  end

  private

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
