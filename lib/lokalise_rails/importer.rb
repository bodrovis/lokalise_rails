# frozen_string_literal: true
require 'pry'
class LokaliseRails
  class Importer
    class << self
      def import!
        if LokaliseRails.import_safe_mode && !Dir.empty?(LokaliseRails.loc_path.to_s)
          $stdout.puts "The target directory #{LokaliseRails.loc_path} is not empty!"
          $stdout.print 'Enter Y to continue: '
          answer = $stdin.gets
          return "Task cancelled!" unless answer.to_s.strip == 'Y'
        end

        archive_path = download_files()["bundle_url"]
        Zip::File.open_buffer(open(archive_path)) do |zip|
          zip.each do |entry|
            next unless /\.ya?ml/.match?(entry.name)

            filename = entry.name.include?('/') ? entry.name.split('/')[1] : entry.name
            data = YAML.load entry.get_input_stream.read
            File.open("#{LokaliseRails.loc_path}/#{filename}", 'w+:UTF-8') do |f|
              f.write(data.to_yaml)
            end
          end
        end

        "Task complete!"
      end

      def download_files
        client = Lokalise.client LokaliseRails.api_token
        opts = LokaliseRails.import_opts

        client.download_files LokaliseRails.project_id, opts
      end
    end
  end
end
