# frozen_string_literal: true

require 'pathname'

describe LokaliseRails::Utils do
  describe '.rails_root' do
    it 'fallbacks if neither roots are present' do
      allow(Rails).to receive(:root).and_return(nil)
      expect(described_class.rails_root).to be_nil
    end
  end

  describe '.require_config!' do
    context 'when the config file does not exist' do
      it 'aborts with a helpful message' do
        Dir.mktmpdir do |dir|
          allow(described_class).to receive(:root).
            and_return(Pathname.new(dir))

          expect do
            described_class.require_config!
          end.to output(
            /LokaliseRails configuration file was not found.*rails generate lokalise_rails:install/m
          ).to_stderr.
            and raise_error(SystemExit) { |error|
                  expect(error.status).to eq(1)
                }
        end
      end
    end
  end
end
