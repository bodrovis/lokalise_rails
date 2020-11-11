# frozen_string_literal: true

describe LokaliseRails::TaskDefinition::Importer do
  describe '.open_and_process_zip' do
    let(:faulty_trans) { "#{Rails.root}/public/faulty_trans.zip" }

    it 'rescues from errors during file processing' do
      expect(-> { described_class.open_and_process_zip(faulty_trans) }).
        to output(/Psych::DisallowedClass/).to_stdout
    end
  end

  describe '.download_files' do
    it 'returns a proper download URL' do
      allow_project_id '189934715f57a162257d74.88352370' do
        response = VCR.use_cassette('download_files') do
          described_class.download_files
        end

        expect(response['project_id']).to eq('189934715f57a162257d74.88352370')
        expect(response['bundle_url']).to include('s3-eu-west-1.amazonaws.com')
      end
    end

    it 'rescues from errors during file download' do
      allow_project_id 'invalid'
      VCR.use_cassette('download_files_error') do
        expect(-> { described_class.download_files }).
          to output(/Lokalise::Error::BadRequest/).to_stdout
      end
    end
  end

  describe '.import!' do
    it 'halts when the API key is not set' do
      allow(LokaliseRails).to receive(:api_token).and_return(nil)
      expect(-> { described_class.import! }).to output(/API token is not set/).to_stdout
      expect(LokaliseRails).to have_received(:api_token)
      expect(count_translations).to eq(0)
    end

    it 'halts when the project_id is not set' do
      allow_project_id nil do
        expect(-> { described_class.import! }).to output(/Project ID is not set/).to_stdout
        expect(count_translations).to eq(0)
      end
    end
  end
end
