# frozen_string_literal: true

require 'ruby-lokalise-api'
require 'pathname'
require 'pry'
require "ostruct"

module LokaliseRails
  module TaskDefinition
    class Base
      attr_reader :global_opts
      
      def initialize(custom_opts = {})
        primary_opts = LokaliseRails.singleton_methods.filter {|m| m.to_s.end_with?('=')}.inject({}) do |opts, method|
          reader = method.to_s.delete_suffix('=')
          opts[reader.to_sym] = LokaliseRails.send(reader)
          opts
        end

        @global_opts = OpenStruct.new primary_opts.merge(custom_opts)
      end

      # Creates a Lokalise API client
      #
      # @return [Lokalise::Client]
      def api_client
        @api_client ||= ::Lokalise.client global_opts.api_token, {enable_compression: true}.merge(global_opts.timeouts)
      end

      # Resets API client
      def reset_api_client!
        Lokalise.reset_client!
        @api_client = nil
      end

      private
      
      # Checks task options
      #
      # @return Array
      def check_options_errors!
        errors = []
        errors << 'Project ID is not set!' if global_opts.project_id.nil? || global_opts.project_id.empty?
        errors << 'Lokalise API token is not set!' if global_opts.api_token.nil? || global_opts.api_token.empty?

        raise(LokaliseRails::Error, errors.join(' ')) if errors.any?
      end

      # Checks whether the provided file has a proper extension as dictated by the `file_ext_regexp` option
      #
      # @return Boolean
      # @param raw_path [String, Pathname]
      def proper_ext?(raw_path)
        path = raw_path.is_a?(Pathname) ? raw_path : Pathname.new(raw_path)
        global_opts.file_ext_regexp.match? path.extname
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
        "#{global_opts.project_id}:#{global_opts.branch}"
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
