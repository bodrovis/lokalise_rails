require "base64"

module LokaliseRails
  module TaskDefinition
    class Exporter < Base
      class << self
        def export!
          path = LokaliseRails.locales_path
          Dir["#{path}/**/*"].each do |f|
            puts '================'

            full_path = Pathname.new f
            puts full_path

            relative_path = full_path.relative_path_from path
            puts relative_path
            puts '================'

            next unless File.file?(f) && has_proper_ext?(f)
            filename = relative_path.split[1].to_s
            content = File.read f

            opts = {
              data: Base64.strict_encode64(content.strip),
              filename: relative_path,
              lang_iso: filename.split('.')[0]
            }
            opts = opts.merge(LokaliseRails.export_opts)
            puts opts

            api_client.upload_file LokaliseRails.project_id, opts
          end
        end
      end
    end
  end
end
