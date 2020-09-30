# frozen_string_literal: true

require 'base64'

describe LokaliseRails::TaskDefinition::Exporter do
  let(:filename) { 'en.yml' }
  let(:path) { "#{Rails.root}/config/locales/nested/#{filename}" }
  let(:relative_name) { "nested/#{filename}" }

  context 'with one translation file' do
    before :all do
      add_translation_files!
    end

    after :all do
      rm_translation_files
    end

    describe '.export!' do
      it 'sends a proper API request' do
        process = VCR.use_cassette('upload_files') do
          described_class.export!
        end.first

        expect(process.project_id).to eq(LokaliseRails.project_id)
        expect(process.status).to eq('queued')
      end

      it 'halts when the API key is not set' do
        expect(LokaliseRails).to receive(:api_token).and_return(nil)
        expect(described_class).not_to receive(:each_file)
        expect(-> { described_class.export! }).to output(/API token is not set/).to_stdout
      end

      it 'halts when the project_id is not set' do
        expect(LokaliseRails).to receive(:project_id).and_return(nil)
        expect(described_class).not_to receive(:each_file)
        expect(-> { described_class.export! }).to output(/Project ID is not set/).to_stdout
      end
    end

    describe '.each_file' do
      it 'yield proper arguments' do
        expect { |b| described_class.each_file(&b) }.to yield_with_args(
          Pathname.new(path),
          Pathname.new(relative_name),
          filename
        )
      end
    end

    describe '.opts' do
      let(:base64content) { Base64.strict_encode64(File.read(path).strip) }

      it 'generates proper options' do
        resulting_opts = described_class.opts(path, relative_name, filename)

        expect(resulting_opts[:data]).to eq(base64content)
        expect(resulting_opts[:filename]).to eq(relative_name)
        expect(resulting_opts[:lang_iso]).to eq('en')
      end

      it 'allows to redefine options' do
        expect(LokaliseRails).to receive(:export_opts).and_return({
                                                                    detect_icu_plurals: true,
                                                                    convert_placeholders: true
                                                                  })

        resulting_opts = described_class.opts(path, relative_name, filename)

        expect(resulting_opts[:data]).to eq(base64content)
        expect(resulting_opts[:filename]).to eq(relative_name)
        expect(resulting_opts[:lang_iso]).to eq('en')
        expect(resulting_opts[:detect_icu_plurals]).to be true
        expect(resulting_opts[:convert_placeholders]).to be true
      end
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

    describe '.each_file' do
      it 'yields every translation file' do
        expect { |b| described_class.each_file(&b) }.to yield_successive_args(
          [
            Pathname.new(path),
            Pathname.new(relative_name),
            filename
          ],
          [
            Pathname.new(path_ru),
            Pathname.new(relative_name_ru),
            filename_ru
          ]
        )
      end

      it 'does not yield files that have to be skipped' do
        expect(LokaliseRails).to receive(:skip_file_export).twice.and_return(
          ->(f) { f.split[1].to_s.include?('ru') }
        )
        expect { |b| described_class.each_file(&b) }.to yield_successive_args(
          [
            Pathname.new(path),
            Pathname.new(relative_name),
            filename
          ]
        )
      end
    end
  end
end
