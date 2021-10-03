# frozen_string_literal: true

require 'fileutils'

RSpec.describe 'Import Rake task' do
  let(:local_trans) { "#{Rails.root}/public/trans.zip" }
  let(:remote_trans) { 'https://github.com/bodrovis/lokalise_rails/blob/master/spec/dummy/public/trans.zip?raw=true' }

  let(:described_klass) { LokaliseRails::TaskDefinition::Importer }
  let(:importer_object) { described_klass.new }
  let(:top_object) { LokaliseRails }
  let(:loc_path) { importer_object.global_opts.locales_path }

  it 'handles too many requests' do
    allow_task_def_instance described_klass, importer_object
    allow_project_id importer_object, '672198945b7d72fc048021.15940510'
    allow(importer_object.global_opts).to receive(:max_retries_import).and_return(2)
    allow(importer_object).to receive(:sleep).and_return(0)

    fake_client = double
    allow(fake_client).to receive(:download_files).and_raise(Lokalise::Error::TooManyRequests)
    allow(importer_object).to receive(:api_client).and_return(fake_client)

    expect(import_executor).to raise_error(SystemExit, /Gave up after 2 retries/i)

    expect(importer_object).to have_received(:sleep).exactly(2).times
    expect(importer_object.global_opts).to have_received(:max_retries_import).exactly(1).times
    expect(importer_object).to have_received(:api_client).exactly(3).times
    expect(fake_client).to have_received(:download_files).exactly(3).times
  end

  it 'halts when the API key is not set' do
    allow(top_object).to receive(:api_token).and_return(nil)

    expect(import_executor).to raise_error(SystemExit, /API token is not set/i)
    expect(top_object).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow(top_object).to receive(:project_id).and_return(nil)

    expect(import_executor).to raise_error(SystemExit, /ID is not set/i)

    expect(top_object).to have_received(:project_id)
  end

  context 'when directory is empty' do
    before do
      mkdir_locales
      rm_translation_files
    end

    after :all do
      rm_translation_files
    end

    it 'import rake task is callable' do
      allow_task_def_instance described_klass, importer_object

      allow(importer_object).to receive(:download_files).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => local_trans
        }
      )

      expect(import_executor).to output(/complete!/).to_stdout

      expect(count_translations).to eq(4)
      expect(importer_object).to have_received(:download_files)
      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end

    it 'import rake task downloads ZIP archive properly' do
      allow_task_def_instance described_klass, importer_object

      allow(importer_object).to receive(:download_files).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => remote_trans
        }
      )

      expect(import_executor).to output(/complete!/).to_stdout

      expect(importer_object).to have_received(:download_files)
      expect(count_translations).to eq(4)
      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end
  end

  context 'when directory is not empty and safe mode enabled' do
    before :all do
      mkdir_locales
      LokaliseRails.import_safe_mode = true
    end

    before do
      rm_translation_files
      add_translation_files!
    end

    after :all do
      rm_translation_files
      LokaliseRails.import_safe_mode = false
    end

    it 'import proceeds when the user agrees' do
      allow_task_def_instance described_klass, importer_object

      allow(importer_object).to receive(:download_files).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => local_trans
        }
      )

      allow($stdin).to receive(:gets).and_return('Y')
      expect(import_executor).to output(/is not empty/).to_stdout

      expect(count_translations).to eq(5)
      expect($stdin).to have_received(:gets)
      expect(importer_object).to have_received(:download_files)
      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end

    it 'import halts when a user chooses not to proceed' do
      allow_task_def_instance described_klass, importer_object

      allow(importer_object).to receive(:download_files).at_most(0).times
      allow($stdin).to receive(:gets).and_return('N')
      expect(import_executor).to output(/is not empty/).to_stdout

      expect(importer_object).not_to have_received(:download_files)
      expect($stdin).to have_received(:gets)
      expect(count_translations).to eq(1)
    end
  end
end
