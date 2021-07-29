# frozen_string_literal: true

RSpec.describe LokaliseRails do
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

  it 'runs export rake task properly' do
    expect(export_executor).to output(/complete!/).to_stdout
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
