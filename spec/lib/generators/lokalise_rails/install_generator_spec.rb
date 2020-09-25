# frozen_string_literal: true

describe LokaliseRails do
  before :all do
    remove_config
  end

  after :all do
    remove_config
    install_invoker
  end

  it 'installs config file properly' do
    install_invoker
    expect(File.file?(config_file)).to be true
  end
end
