# frozen_string_literal: true

module FileUtils
  def mkdir_locales
    FileUtils.mkdir_p(LokaliseRails.locales_path) unless File.directory?(LokaliseRails.locales_path)
  end

  def rm_translation_files
    FileUtils.rm_rf locales_dir
  end

  def locales_dir
    Dir["#{LokaliseRails.locales_path}/*"]
  end

  def count_translations
    locales_dir.count { |file| File.file?(file) }
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
end
