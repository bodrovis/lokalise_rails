# frozen_string_literal: true

require 'fileutils'

RSpec.describe LokaliseRails do
  let(:loc_path) { described_class.locales_path }
  let(:local_trans) { "#{Rails.root}/public/trans.zip" }
  let(:remote_trans) { 'https://github.com/bodrovis/lokalise_rails/blob/master/spec/dummy/public/trans.zip?raw=true' }

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
