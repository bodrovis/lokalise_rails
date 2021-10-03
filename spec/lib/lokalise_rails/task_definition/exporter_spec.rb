# frozen_string_literal: true

require 'base64'

describe LokaliseRails::TaskDefinition::Exporter do
  let(:filename) { 'en.yml' }
  let(:path) { "#{LokaliseRails::Utils.root}/config/locales/nested/#{filename}" }
  let(:relative_name) { "nested/#{filename}" }
  let(:described_object) { described_class.new }

  context 'with many translation files' do
    before :all do
      add_translation_files! with_ru: true, additional: 5
    end

    after :all do
      rm_translation_files
    end

    describe '.export!' do
      it 'sends a proper API request and handles rate limiting' do
        allow_project_id described_object, '672198945b7d72fc048021.15940510'

        process = VCR.use_cassette('upload_files_multiple') do
          described_object.export!
        end.first

        expect(process.project_id).to eq(LokaliseRails.project_id)
        expect(process.status).to eq('queued')
      end

      it 'handles too many requests' do
        allow_project_id described_object, '672198945b7d72fc048021.15940510'

        allow(described_object.global_opts).to receive(:max_retries_export).and_return(2)
        allow(described_object).to receive(:sleep).and_return(0)

        fake_client = double
        allow(fake_client).to receive(:upload_file).with(any_args).and_raise(Lokalise::Error::TooManyRequests)
        allow(described_object).to receive(:api_client).and_return(fake_client)

        expect(-> { described_object.export! }).to raise_error(Lokalise::Error::TooManyRequests, /Gave up after 2 retries/i)

        expect(described_object).to have_received(:sleep).exactly(2).times
        expect(described_object.global_opts).to have_received(:max_retries_export).exactly(1).times
        expect(described_object).to have_received(:api_client).exactly(3).times
        expect(fake_client).to have_received(:upload_file).exactly(3).times
      end
    end
  end

  context 'with one translation file' do
    before :all do
      add_translation_files!
    end

    after :all do
      rm_translation_files
    end

    describe '.export!' do
      it 'sends a proper API request' do
        allow_project_id described_object

        process = VCR.use_cassette('upload_files') do
          described_object.export!
        end.first

        expect(process.project_id).to eq(described_object.global_opts.project_id)
        expect(process.status).to eq('queued')
        expect(described_object.global_opts.max_retries_export).to eq(5)
      end

      it 'sends a proper API request when a different branch is provided' do
        allow_project_id described_object
        
        allow(described_object.global_opts).to receive(:branch).and_return('develop')

        process = VCR.use_cassette('upload_files_branch') do
          described_object.export!
        end.first

        expect(described_object.global_opts).to have_received(:branch)
        expect(process.project_id).to eq(described_object.global_opts.project_id)
        expect(process.status).to eq('queued')
      end

      it 'halts when the API key is not set' do
        allow(described_object.global_opts).to receive(:api_token).and_return(nil)

        expect(-> { described_object.export! }).to raise_error(LokaliseRails::Error, /API token is not set/i)
        expect(described_object.global_opts).to have_received(:api_token)
      end

      it 'halts when the project_id is not set' do
        allow_project_id described_object, nil do
          expect(-> { described_object.export! }).to raise_error(LokaliseRails::Error, /ID is not set/i)
        end
      end
    end

    describe '.each_file' do
      it 'yield proper arguments' do
        expect { |b| described_object.send(:each_file, &b) }.to yield_with_args(
          Pathname.new(path),
          Pathname.new(relative_name)
        )
      end
    end

    describe '.opts' do
      let(:base64content) { Base64.strict_encode64(File.read(path).strip) }

      it 'generates proper options' do
        resulting_opts = described_object.send(:opts, path, relative_name)

        expect(resulting_opts[:data]).to eq(base64content)
        expect(resulting_opts[:filename]).to eq(relative_name)
        expect(resulting_opts[:lang_iso]).to eq('en')
      end

      it 'allows to redefine options' do
        allow(described_object.global_opts).to receive(:export_opts).and_return({
                                                                   detect_icu_plurals: true,
                                                                   convert_placeholders: true
                                                                 })

        resulting_opts = described_object.send(:opts, path, relative_name)

        expect(described_object.global_opts).to have_received(:export_opts)
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
      it 're-raises export errors' do
        allow_project_id described_object

        VCR.use_cassette('upload_files_error') do
          expect { described_object.export! }.to raise_error(Lokalise::Error::BadRequest, /Unknown `lang_iso`/)
        end
      end
    end

    describe '.opts' do
      let(:base64content_ru) { Base64.strict_encode64(File.read(path_ru).strip) }

      it 'generates proper options' do
        resulting_opts = described_object.send(:opts, path_ru, relative_name_ru)

        expect(resulting_opts[:data]).to eq(base64content_ru)
        expect(resulting_opts[:filename]).to eq(relative_name_ru)
        expect(resulting_opts[:lang_iso]).to eq('ru_RU')
      end
    end

    describe '.each_file' do
      it 'yields every translation file' do
        expect { |b| described_object.send(:each_file, &b) }.to yield_successive_args(
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
        allow(described_object.global_opts).to receive(:skip_file_export).twice.and_return(
          ->(f) { f.split[1].to_s.include?('ru') }
        )
        expect { |b| described_object.send(:each_file, &b) }.to yield_successive_args(
          [
            Pathname.new(path),
            Pathname.new(relative_name)
          ]
        )

        expect(described_object.global_opts).to have_received(:skip_file_export).twice
      end
    end
  end
end
