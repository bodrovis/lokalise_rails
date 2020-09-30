# frozen_string_literal: true

require 'fileutils'

module FileManager
  def expect_file_exist(path, file)
    file_path = File.join path, file
    expect(File.file?(file_path)).to be true
  end

  def mkdir_locales
    FileUtils.mkdir_p(LokaliseRails.locales_path) unless File.directory?(LokaliseRails.locales_path)
  end

  def rm_translation_files
    FileUtils.rm_rf locales_dir
  end

  def locales_dir
    Dir["#{LokaliseRails.locales_path}/**/*"]
  end

  def count_translations
    locales_dir.count { |file| File.file?(file) }
  end

  def add_translation_files!(with_ru: false)
    FileUtils.mkdir_p "#{Rails.root}/config/locales/nested"
    File.open("#{Rails.root}/config/locales/nested/en.yml", 'w+:UTF-8') do |f|
      f.write en_data
    end

    return unless with_ru

    File.open("#{Rails.root}/config/locales/ru.yml", 'w+:UTF-8') do |f|
      f.write ru_data
    end
  end

  def add_config!
    data = <<~DATA
      require 'lokalise_rails'
      LokaliseRails.config do |c|
        c.api_token = ENV['LOKALISE_API_TOKEN']
        c.project_id = ENV['LOKALISE_PROJECT_ID']
      end
    DATA

    File.open("#{Rails.root}/config/lokalise_rails.rb", 'w+:UTF-8') do |f|
      f.write data
    end
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
      ru:
        my_key: "Моё значение"
        nested:
          key: "Значение 2"
    DATA
  end
end
