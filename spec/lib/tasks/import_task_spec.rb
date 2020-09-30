# frozen_string_literal: true

require 'fileutils'

RSpec.describe LokaliseRails do
  context 'when directory is empty' do
    before do
      mkdir_locales
      rm_translation_files
    end

    after :all do
      rm_translation_files
    end

    let(:loc_path) { described_class.locales_path }

    it 'is callable' do
      expect(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => "#{Rails.root}/public/translations.zip"
        }
      )

      expect(import_executor).to output(/complete!/).to_stdout

      expect(count_translations).to eq(4)

      expect_file_exist loc_path, 'en/nested/main_en.yml'
      expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
      expect_file_exist loc_path, 'ru/main_ru.yml'
    end

    it 'downloads ZIP archive properly' do
      expect(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => 'https://github.com/bodrovis/lokalise_rails/blob/master/spec/dummy/public/translations.zip?raw=true'
        }
      )

      expect(import_executor).to output(/complete!/).to_stdout

      expect(count_translations).to eq(4)

      expect_file_exist loc_path, 'en/main_en.yml'
    end
  end

  context 'when directory is not empty' do
    before :all do
      mkdir_locales
      rm_translation_files
      add_translation_files!
      described_class.import_safe_mode = true
    end

    after :all do
      rm_translation_files
      described_class.import_safe_mode = false
    end

    it 'returns a success message with default settings' do
      expect(LokaliseRails::TaskDefinition::Importer).to receive(
        :download_files
      ).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => "#{Rails.root}/public/translations.zip"
        }
      )
      expect($stdin).to receive(:gets).and_return('Y')
      expect(import_executor).to output(/is not empty/).to_stdout

      expect(count_translations).to eq(5)
    end
  end
end
