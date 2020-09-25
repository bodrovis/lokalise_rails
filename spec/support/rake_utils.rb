# frozen_string_literal: true

module RakeUtils
  def import_executor
    -> { Rake::Task['lokalise_rails:import'].execute }
  end

  def install_invoker
    Rails::Generators.invoke 'lokalise_rails:install'
  end
end
