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
        allow_project_id

        process = VCR.use_cassette('upload_files') do
          described_class.export!
        end.first

        expect(process.project_id).to eq(LokaliseRails.project_id)
        expect(process.status).to eq('queued')
      end

      it 'sends a proper API request when a different branch is provided' do
        allow_project_id
        allow(LokaliseRails).to receive(:branch).and_return('develop')

        process = VCR.use_cassette('upload_files_branch') do
          described_class.export!
        end.first

        expect(LokaliseRails).to have_received(:branch)
        expect(process.project_id).to eq(LokaliseRails.project_id)
        expect(process.status).to eq('queued')
      end

      it 'halts when the API key is not set' do
        allow(LokaliseRails).to receive(:api_token).and_return(nil)

        expect(-> { described_class.export! }).to output(/API token is not set/).to_stdout
        expect(LokaliseRails).to have_received(:api_token)
      end

      it 'halts when the project_id is not set' do
        allow(LokaliseRails).to receive(:project_id).and_return(nil)

        expect(-> { described_class.export! }).to output(/Project ID is not set/).to_stdout
        expect(LokaliseRails).to have_received(:project_id)
      end
    end

    describe '.each_file' do
      it 'yield proper arguments' do
        expect { |b| described_class.each_file(&b) }.to yield_with_args(
          Pathname.new(path),
          Pathname.new(relative_name)
        )
      end
    end

    describe '.opts' do
      let(:base64content) { Base64.strict_encode64(File.read(path).strip) }

      it 'generates proper options' do
        resulting_opts = described_class.opts(path, relative_name)

        expect(resulting_opts[:data]).to eq(base64content)
        expect(resulting_opts[:filename]).to eq(relative_name)
        expect(resulting_opts[:lang_iso]).to eq('en')
      end

      it 'allows to redefine options' do
        allow(LokaliseRails).to receive(:export_opts).and_return({
                                                                   detect_icu_plurals: true,
                                                                   convert_placeholders: true
                                                                 })

        resulting_opts = described_class.opts(path, relative_name)

        expect(LokaliseRails).to have_received(:export_opts)
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

    describe '.export!' do
      it 'rescues from export errors' do
        allow_project_id

        processes = VCR.use_cassette('upload_files_error') do
          described_class.export!
        end

        expect(processes.length).to eq(1)
        process = processes.first
        expect(process.project_id).to eq(LokaliseRails.project_id)
        expect(process.status).to eq('queued')
      end
    end

    describe '.opts' do
      let(:base64content_ru) { Base64.strict_encode64(File.read(path_ru).strip) }

      it 'generates proper options' do
        resulting_opts = described_class.opts(path_ru, relative_name_ru)

        expect(resulting_opts[:data]).to eq(base64content_ru)
        expect(resulting_opts[:filename]).to eq(relative_name_ru)
        expect(resulting_opts[:lang_iso]).to eq('ru_RU')
      end
    end

    describe '.each_file' do
      it 'yields every translation file' do
        expect { |b| described_class.each_file(&b) }.to yield_successive_args(
          [
            Pathname.new(path),
            Pathname.new(relative_name)
          ],
          [
            Pathname.new(path_ru),
            Pathname.new(relative_name_ru)
          ]
        )
      end

      it 'does not yield files that have to be skipped' do
        allow(LokaliseRails).to receive(:skip_file_export).twice.and_return(
          ->(f) { f.split[1].to_s.include?('ru') }
        )
        expect { |b| described_class.each_file(&b) }.to yield_successive_args(
          [
            Pathname.new(path),
            Pathname.new(relative_name)
          ]
        )

        expect(LokaliseRails).to have_received(:skip_file_export).twice
      end
    end
  end
end
