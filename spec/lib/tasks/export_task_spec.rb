# frozen_string_literal: true

RSpec.describe 'Export Rake task' do
  let(:global_config) { LokaliseRails::GlobalConfig }

  it 'halts when the API key is not set' do
    allow(global_config).to receive(:api_token).and_return(nil)

    expect { Rake::Task['lokalise_rails:export'].execute }.to raise_error(SystemExit, /API token is not set/i)
    expect(global_config).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow(global_config).to receive(:project_id).and_return(nil)

    expect { Rake::Task['lokalise_rails:export'].execute }.to raise_error(SystemExit, /ID is not set/i)

    expect(global_config).to have_received(:project_id)
  end

  context 'with two translation files' do
    let(:filename_ru) { 'ru.yml' }
    let(:path_ru) { "#{Rails.root}/config/locales/#{filename_ru}" }

    before do
      add_translation_files! with_ru: true
    end

    after do
      rm_translation_files
    end

    describe 'export' do
      it 'is callable' do
        allow_project_id global_config, ENV['LOKALISE_PROJECT_ID'] do
          VCR.use_cassette('upload_files') do
            expect { Rake::Task['lokalise_rails:export'].execute }.to output(/complete!/).to_stdout
          end
        end
      end

      it 're-raises export errors' do
        allow_project_id global_config, '542886116159f798720dc4.94769464' do
          VCR.use_cassette('upload_files_error') do
            expect { Rake::Task['lokalise_rails:export'].execute }.to raise_error(SystemExit, /Unknown `lang_iso`/)
          end
        end
      end
    end
  end
end
