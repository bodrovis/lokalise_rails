# frozen_string_literal: true

require 'fileutils'

RSpec.describe LokaliseRails do
  let(:loc_path) { described_class.locales_path }
  let(:local_trans) { "#{Rails.root}/public/trans.zip" }
  let(:remote_trans) { 'https://github.com/bodrovis/lokalise_rails/blob/master/spec/dummy/public/trans.zip?raw=true' }

  let(:fake_importer) { LokaliseRails::TaskDefinition::Importer }

  it 'handles too many requests' do
    allow_project_id '672198945b7d72fc048021.15940510'
    allow(described_class).to receive(:max_retries_import).and_return(2)
    allow(fake_importer).to receive(:sleep).and_return(0)

    fake_client = double
    allow(fake_client).to receive(:download_files).and_raise(Lokalise::Error::TooManyRequests)
    allow(fake_importer).to receive(:api_client).and_return(fake_client)

    expect(import_executor).to raise_error(SystemExit, /Gave up after 2 retries/i)

    expect(fake_importer).to have_received(:sleep).exactly(2).times
    expect(described_class).to have_received(:max_retries_import).exactly(1).times
    expect(fake_importer).to have_received(:api_client).exactly(3).times
    expect(fake_client).to have_received(:download_files).exactly(3).times
  end

  it 'halts when the API key is not set' do
    allow(described_class).to receive(:api_token).and_return(nil)

    expect(import_executor).to raise_error(SystemExit, /API token is not set/i)
    expect(described_class).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow_project_id nil do
      expect(import_executor).to raise_error(SystemExit, /ID is not set/i)
    end
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
      allow(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => local_trans
        }
      )

      expect(import_executor).to output(/complete!/).to_stdout

      expect(count_translations).to eq(4)
      expect(LokaliseRails::TaskDefinition::Importer).to have_received(:download_files)
      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end

    it 'import rake task downloads ZIP archive properly' do
      allow(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => remote_trans
        }
      )

      expect(import_executor).to output(/complete!/).to_stdout

      expect(LokaliseRails::TaskDefinition::Importer).to have_received(:download_files)
      expect(count_translations).to eq(4)
      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end
  end

  context 'when directory is not empty and safe mode enabled' do
    before :all do
      mkdir_locales
      described_class.import_safe_mode = true
    end

    before do
      rm_translation_files
      add_translation_files!
    end

    after :all do
      rm_translation_files
      described_class.import_safe_mode = false
    end

    it 'import proceeds when the user agrees' do
      allow(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => local_trans
        }
      )

      allow($stdin).to receive(:gets).and_return('Y')
      expect(import_executor).to output(/is not empty/).to_stdout

      expect(count_translations).to eq(5)
      expect($stdin).to have_received(:gets)
      expect(LokaliseRails::TaskDefinition::Importer).to have_received(:download_files)
      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end

    it 'import halts when a user chooses not to proceed' do
      allow(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).at_most(0).times
      allow($stdin).to receive(:gets).and_return('N')
      expect(import_executor).to output(/is not empty/).to_stdout

      expect(LokaliseRails::TaskDefinition::Importer).not_to have_received(:download_files)
      expect($stdin).to have_received(:gets)
      expect(count_translations).to eq(1)
    end
  end
end
