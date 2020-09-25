# frozen_string_literal: true

require 'ruby-lokalise-api'
require 'open-uri'

class LokaliseRails
  class Importer
    class << self
      def import!
        return 'Task cancelled!' unless proceed_when_safe_mode?

        archive_path = download_files['bundle_url']
        Zip::File.open_buffer(URI.open(archive_path)) { |zip| process_zip zip }

        'Task complete!'
      end

      def download_files
        client = ::Lokalise.client LokaliseRails.api_token
        opts = LokaliseRails.import_opts

        client.download_files LokaliseRails.project_id, opts
      end

      def process_zip(zip)
        zip.each do |entry|
          next unless /\.ya?ml/.match?(entry.name)

          filename = entry.name.include?('/') ? entry.name.split('/')[1] : entry.name
          data = YAML.safe_load entry.get_input_stream.read
          File.open("#{LokaliseRails.locales_path}/#{filename}", 'w+:UTF-8') do |f|
            f.write(data.to_yaml)
          end
        end
      end

      def proceed_when_safe_mode?
        return true unless LokaliseRails.import_safe_mode && !Dir.empty?(LokaliseRails.locales_path.to_s)

        $stdout.puts "The target directory #{LokaliseRails.locales_path} is not empty!"
        $stdout.print 'Enter Y to continue: '
        answer = $stdin.gets
        answer.to_s.strip == 'Y'
      end
    end
  end
end
