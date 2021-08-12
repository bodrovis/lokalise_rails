# frozen_string_literal: true

require 'ruby-lokalise-api'
require 'pathname'

module LokaliseRails
  module TaskDefinition
    class Base
      class << self
        attr_writer :api_client

        # Creates a Lokalise API client
        #
        # @return [Lokalise::Client]
        def api_client
          @api_client ||= ::Lokalise.client LokaliseRails.api_token, {enable_compression: true}.merge(LokaliseRails.timeouts)
        end

        # Resets API client
        def reset_api_client!
          Lokalise.reset_client!
          @api_client = nil
        end

        # Checks task options
        #
        # @return Array
        def check_options_errors!
          errors = []
          errors << 'Project ID is not set!' if LokaliseRails.project_id.nil? || LokaliseRails.project_id.empty?
          errors << 'Lokalise API token is not set!' if LokaliseRails.api_token.nil? || LokaliseRails.api_token.empty?

          raise(LokaliseRails::Error, errors.join(' ')) if errors.any?
        end

        private

        # Checks whether the provided file has a proper extension as dictated by the `file_ext_regexp` option
        #
        # @return Boolean
        # @param raw_path [String, Pathname]
        def proper_ext?(raw_path)
          path = raw_path.is_a?(Pathname) ? raw_path : Pathname.new(raw_path)
          LokaliseRails.file_ext_regexp.match? path.extname
        end

        # Returns directory and filename for the given entry
        #
        # @return Array
        # @param entry [String]
        def subdir_and_filename_for(entry)
          Pathname.new(entry).split
        end

        # Returns Lokalise project ID and branch, semicolumn separated
        #
        # @return [String]
        def project_id_with_branch
          "#{LokaliseRails.project_id}:#{LokaliseRails.branch}"
        end

        # Sends request with exponential backoff mechanism
        def with_exp_backoff(max_retries)
          return unless block_given?

          retries = 0
          begin
            yield
          rescue Lokalise::Error::TooManyRequests => e
            raise(e.class, "Gave up after #{retries} retries") if retries >= max_retries

            sleep 2**retries
            retries += 1
            retry
          end
        end
      end
    end
  end
end
