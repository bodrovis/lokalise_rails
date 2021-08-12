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

  def add_translation_files!(with_ru: false, additional: nil)
    FileUtils.mkdir_p "#{Rails.root}/config/locales/nested"
    open_and_write("config/locales/nested/en.yml") { |f| f.write en_data }

    return unless with_ru

    open_and_write("config/locales/ru.yml") { |f| f.write ru_data }

    return unless additional

    additional.times do |i|
      data = {"en"=>{"key_#{i}"=>"value #{i}"}}

      open_and_write("config/locales/en_#{i}.yml") { |f| f.write data.to_yaml }
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

    open_and_write("config/lokalise_rails.rb") { |f| f.write data }
  end

  def open_and_write(rel_path)
    return unless block_given?

    File.open("#{Rails.root}/#{rel_path}", 'w+:UTF-8') do |f|
      yield f
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
      ru_RU:
        my_key: "Моё значение"
        nested:
          key: "Значение 2"
    DATA
  end
end
