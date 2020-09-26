# frozen_string_literal: true

require 'generators/lokalise_rails/install_generator'

describe LokaliseRails::Generators::InstallGenerator do
  before :all do
    remove_config
  end

  after :all do
    remove_config
    described_class.start
  end

  it 'installs config file properly' do
    described_class.start
    expect(File.file?(config_file)).to be true
  end
end
