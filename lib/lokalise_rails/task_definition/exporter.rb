# frozen_string_literal: true

require 'base64'

module LokaliseRails
  module TaskDefinition
    class Exporter < Base
      class << self
        # Performs translation file export from Rails to Lokalise and returns an array of queued processes
        #
        # @return [Array]
        def export!
          errors = opt_errors

          if errors.any?
            errors.each { |e| $stdout.puts e }
            return false
          end

          queued_processes = []
          each_file do |full_path, relative_path|
            queued_processes << api_client.upload_file(
              LokaliseRails.project_id, opts(full_path, relative_path)
            )
          rescue StandardError => e
            $stdout.puts "Error while trying to upload #{full_path}: #{e.inspect}"
          end

          $stdout.print 'Task complete!'

          queued_processes
        end

        # Processes each translation file in the specified directory
        def each_file
          return unless block_given?

          loc_path = LokaliseRails.locales_path
          Dir["#{loc_path}/**/*"].sort.each do |f|
            full_path = Pathname.new f

            next unless file_matches_criteria? full_path

            relative_path = full_path.relative_path_from Pathname.new(loc_path)

            yield full_path, relative_path
          end
        end

        # Generates export options
        #
        # @return [Hash]
        # @param full_p [Pathname]
        # @param relative_p [Pathname]
        def opts(full_p, relative_p)
          content = File.read full_p

          lang_iso = YAML.safe_load(content)&.keys&.first

          initial_opts = {
            data: Base64.strict_encode64(content.strip),
            filename: relative_p,
            lang_iso: lang_iso
          }

          initial_opts.merge LokaliseRails.export_opts
        end

        # Checks whether the specified file has to be processed or not
        #
        # @return [Boolean]
        # @param full_path [Pathname]
        def file_matches_criteria?(full_path)
          full_path.file? && proper_ext?(full_path) &&
            !LokaliseRails.skip_file_export.call(full_path)
        end
      end
    end
  end
end
