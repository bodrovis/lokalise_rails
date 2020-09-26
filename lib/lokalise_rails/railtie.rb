# frozen_string_literal: true

class LokaliseRails
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[
        File.join(File.dirname(__FILE__), '..', 'tasks', '**/*.rake')
      ].each { |rake| load rake }
    end
  end
end
