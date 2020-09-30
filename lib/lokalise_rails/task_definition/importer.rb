# frozen_string_literal: true

require 'zip'
require 'yaml'
require 'open-uri'
require 'fileutils'

module LokaliseRails
  module TaskDefinition
    class Importer < Base
      class << self
        def import!
          errors = opt_errors

          if errors.any?
            errors.each { |e| $stdout.puts e }
            return false
          end

          unless proceed_when_safe_mode?
            $stdout.print 'Task cancelled!'
            return false
          end

          open_and_process_zip download_files['bundle_url']

          $stdout.print 'Task complete!'
          true
        end

        def download_files
          opts = LokaliseRails.import_opts

          api_client.download_files LokaliseRails.project_id, opts
        end

        def open_and_process_zip(path)
          Zip::File.open_buffer(URI.open(path)) { |zip| process_zip zip }
        end

        def process_zip(zip)
          zip.each do |entry|
            next unless proper_ext? entry.name

            data = YAML.safe_load entry.get_input_stream.read
            subdir, filename = subdir_and_filename_for entry.name
            full_path = "#{LokaliseRails.locales_path}/#{subdir}"
            FileUtils.mkdir_p full_path

            File.open(File.join(full_path, filename), 'w+:UTF-8') do |f|
              f.write data.to_yaml
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
