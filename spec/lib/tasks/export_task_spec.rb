# frozen_string_literal: true

RSpec.describe LokaliseRails do
  let(:fake_exporter) { LokaliseRails::TaskDefinition::Exporter }

  it 'halts when the API key is not set' do
    allow(described_class).to receive(:api_token).and_return(nil)

    expect(export_executor).to raise_error(SystemExit, /API token is not set/i)
    expect(described_class).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow_project_id nil do
      expect(export_executor).to raise_error(SystemExit, /ID is not set/i)
    end
  end

  context 'with two translation files' do
    let(:filename_ru) { 'ru.yml' }
    let(:path_ru) { "#{Rails.root}/config/locales/#{filename_ru}" }
    let(:relative_name_ru) { filename_ru }

    before :all do
      add_translation_files! with_ru: true
    end

    after :all do
      rm_translation_files
    end

    it 'handles too many requests' do
      allow_project_id '672198945b7d72fc048021.15940510'
      allow(described_class).to receive(:max_retries_export).and_return(2)
      allow(fake_exporter).to receive(:sleep).and_return(0)

      fake_client = double
      allow(fake_client).to receive(:upload_file).and_raise(Lokalise::Error::TooManyRequests)
      allow(fake_exporter).to receive(:api_client).and_return(fake_client)

      expect(export_executor).to raise_error(SystemExit, /Gave up after 2 retries/i)

      expect(fake_exporter).to have_received(:sleep).exactly(2).times
      expect(described_class).to have_received(:max_retries_export).exactly(1).time
      expect(fake_exporter).to have_received(:api_client).exactly(3).times
      expect(fake_client).to have_received(:upload_file).exactly(3).times
    end

    it 'runs export rake task properly' do
      fake_client = double
      allow(fake_client).to receive(:upload_file).and_return(true)
      allow(fake_exporter).to receive(:api_client).and_return(fake_client)

      expect(export_executor).to output(/complete!/).to_stdout

      expect(fake_client).to have_received(:upload_file).exactly(2).times
    end

    describe '.export!' do
      it 're-raises export errors' do
        allow_project_id

        VCR.use_cassette('upload_files_error') do
          expect(export_executor).to raise_error(SystemExit, /Unknown `lang_iso`/)
        end
      end
    end
  end
end
