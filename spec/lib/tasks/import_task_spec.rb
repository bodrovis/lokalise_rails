# frozen_string_literal: true

require 'fileutils'

RSpec.describe 'Import Rake task' do
  let(:global_config) { LokaliseRails::GlobalConfig }
  let(:loc_path) { global_config.locales_path }

  it 'halts when the API key is not set' do
    allow(global_config).to receive(:api_token).and_return(nil)

    expect(import_executor).to raise_error(SystemExit, /API token is not set/i)
    expect(global_config).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow(global_config).to receive(:project_id).and_return(nil)

    expect(import_executor).to raise_error(SystemExit, /ID is not set/i)

    expect(global_config).to have_received(:project_id)
  end

  context 'when directory is empty' do
    before do
      mkdir_locales
      rm_translation_files
    end

    after :all do
      rm_translation_files
    end

    describe 'import' do
      it 'is callable' do
        allow_project_id global_config, ENV['LOKALISE_PROJECT_ID'] do
          VCR.use_cassette('download_files') do
            expect(import_executor).to output(/complete!/).to_stdout
          end

          expect(count_translations).to eq(4)

          expect_file_exist loc_path, 'en.yml'
          expect_file_exist loc_path, 'ru.yml'
          expect_file_exist loc_path, 'yo.yml'
        end
      end

      it 're-raises export errors' do
        allow_project_id global_config, 'fake' do
          VCR.use_cassette('download_files_error') do
            expect(import_executor).to raise_error(SystemExit, /Invalid `project_id` parameter/)
          end
        end
      end
    end
  end
end
