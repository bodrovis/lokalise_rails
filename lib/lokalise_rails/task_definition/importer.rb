# frozen_string_literal: true

class LokaliseRails
  module TaskDefinition
    class Importer < Base
      class << self
        def import!
          status_ok, msg = check_required_opts
          return msg unless status_ok
          return 'Task cancelled!' unless proceed_when_safe_mode?

          open_and_process_zip download_files['bundle_url']

          'Task complete!'
        end

        def download_files
          client = ::Lokalise.client LokaliseRails.api_token
          opts = LokaliseRails.import_opts

          client.download_files LokaliseRails.project_id, opts
        end

        def open_and_process_zip(path)
          Zip::File.open_buffer(URI.open(path)) { |zip| process_zip zip }
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
end
