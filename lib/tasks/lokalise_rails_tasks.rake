# frozen_string_literal: true

require 'rake'
require 'ruby-lokalise-api'
require 'zip'
require 'open-uri'
require 'yaml'

namespace :lokalise_rails do
  task import: :environment do
    if LokaliseRails.safe_mode && !Dir.empty?(LokaliseRails.loc_path.to_s)
      puts "The target directory #{LokaliseRails.loc_path} is not empty!"
      print 'Enter Y to continue: '
      answer = $stdin.gets
      exit unless answer.to_s.strip == 'Y'
    end

    # client = Lokalise.client '7d48f5a35de201230f45e2c29ba8f6cb77e209a6'
    # params = {
    #   format: "yaml",
    #   placeholder_format: :icu,
    #   yaml_include_root: true,
    #   original_filenames: true,
    #   directory_prefix: '',
    #   indentation: '2sp'
    # }
    #
    # resp = client.download_files('189934715f57a162257d74.88352370', params)
    # puts resp
    result = {}

    # Zip::File.open_buffer(open(resp["bundle_url"])) { |zip|
    url = 'https://s3-eu-west-1.amazonaws.com/lokalise-assets/files/export/189934715f57a162257d74.88352370/1a95f9be39ae7219fb2f5ec925505e1b/Export_Demo-locale.zip'
    Zip::File.open_buffer(open(url)) do |zip|
      zip.each do |entry|
        next unless /\.ya?ml/.match?(entry.name)

        filename = entry.name.include?('/') ? entry.name.split('/')[1] : entry.name
        result[filename] = YAML.load entry.get_input_stream.read
      end
    end

    result.each do |filename, data|
      File.open("#{LokaliseRails.loc_path}/#{filename}", 'w+:UTF-8') { |f| f.write(data.to_yaml) }
    end
  end
end
