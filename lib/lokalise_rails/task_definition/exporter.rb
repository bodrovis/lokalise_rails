require "base64"

module LokaliseRails
  module TaskDefinition
    class Exporter < Base
      class << self
        def export!
          errors = opt_errors

          if errors.any?
            errors.each {|e| $stdout.puts e}
            return false
          end

          queued_processes = []
          each_file do |*args|
            queued_processes << api_client.upload_file(
              LokaliseRails.project_id, opts(*args)
            )
          end

          $stdout.print 'Task complete!'

          queued_processes
        end

        def each_file
          return unless block_given?

          loc_path = LokaliseRails.locales_path
          Dir["#{loc_path}/**/*"].each do |f|
            full_path = Pathname.new f

            next unless full_path.file? && has_proper_ext?(full_path)

            relative_path = full_path.relative_path_from loc_path
            filename = relative_path.split[1].to_s

            yield full_path, relative_path, filename
          end
        end

        def opts(full_p, relative_p, filename)
          content = File.read full_p

          initial_opts = {
            data: Base64.strict_encode64(content.strip),
            filename: relative_p,
            lang_iso: filename.split('.')[0]
          }

          initial_opts.merge LokaliseRails.export_opts
        end
      end
    end
  end
end
