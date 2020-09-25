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

  def remove_config
    FileUtils.remove_file config_file if File.file?(config_file)
  end

  def config_file
    "#{Rails.root}/config/initializers/lokalise_rails.rb"
  end
end
