# frozen_string_literal: true

require 'zip'
require 'yaml'
require 'open-uri'
require 'fileutils'

module LokaliseRails
  module TaskDefinition
    class Importer < Base
      class << self
        # Performs translation files import from Lokalise to Rails app
        #
        # @return [Boolean]
        def import!
          check_options_errors!

          unless proceed_when_safe_mode?
            $stdout.print 'Task cancelled!'
            return false
          end

          open_and_process_zip download_files['bundle_url']

          $stdout.print 'Task complete!'
          true
        end

        # Downloads files from Lokalise using the specified options
        #
        # @return [Hash]
        def download_files
          opts = LokaliseRails.import_opts

          api_client.download_files project_id_with_branch, opts
        rescue StandardError => e
          raise e.class, "There was an error when trying to download files: #{e.message}"
        end

        # Opens ZIP archive (local or remote) with translations and processes its entries
        #
        # @param path [String]
        def open_and_process_zip(path)
          Zip::File.open_buffer(open_file_or_remote(path)) do |zip|
            fetch_zip_entries(zip) { |entry| process!(entry) }
          end
        rescue StandardError => e
          raise e.class, "There was an error when trying to process the downloaded files: #{e.message}"
        end

        # Iterates over ZIP entries. Each entry may be a file or folder.
        def fetch_zip_entries(zip)
          return unless block_given?

          zip.each do |entry|
            next unless proper_ext? entry.name

            yield entry
          end
        end

        # Processes ZIP entry by reading its contents and creating the corresponding translation file
        def process!(zip_entry)
          data = data_from zip_entry
          subdir, filename = subdir_and_filename_for zip_entry.name
          full_path = "#{LokaliseRails.locales_path}/#{subdir}"
          FileUtils.mkdir_p full_path

          File.open(File.join(full_path, filename), 'w+:UTF-8') do |f|
            f.write LokaliseRails.translations_converter.call(data)
          end
        rescue StandardError => e
          raise e.class, "Error when trying to process #{zip_entry&.name}: #{e.message}"
        end

        # Checks whether the user wishes to proceed when safe mode is enabled and the target directory is not empty
        #
        # @return [Boolean]
        def proceed_when_safe_mode?
          return true unless LokaliseRails.import_safe_mode && !Dir.empty?(LokaliseRails.locales_path.to_s)

          $stdout.puts "The target directory #{LokaliseRails.locales_path} is not empty!"
          $stdout.print 'Enter Y to continue: '
          answer = $stdin.gets
          answer.to_s.strip == 'Y'
        end

        # Opens a local file or a remote URL using the provided patf
        #
        # @return [String]
        def open_file_or_remote(path)
          parsed_path = URI.parse(path)
          if parsed_path&.scheme&.include?('http')
            parsed_path.open
          else
            File.open path
          end
        end

        private

        def data_from(zip_entry)
          LokaliseRails.translations_loader.call zip_entry.get_input_stream.read
        end
      end
    end
  end
end
