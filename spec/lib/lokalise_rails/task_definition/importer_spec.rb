# frozen_string_literal: true

describe LokaliseRails::TaskDefinition::Importer do
  describe '.open_and_process_zip' do
    let(:faulty_trans) { "#{Rails.root}/public/faulty_trans.zip" }

    it 're-raises errors during file processing' do
      expect(-> { described_class.open_and_process_zip(faulty_trans) }).
        to raise_error(Psych::DisallowedClass, /Error when trying to process fail\.yml/)
    end

    it 're-raises errors during file opening' do
      expect(-> { described_class.open_and_process_zip('http://fake.url/wrong/path.zip') }).
        to raise_error(SocketError, /Failed to open TCP connection/)
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

    it 're-raises errors during file download' do
      allow_project_id 'invalid'
      VCR.use_cassette('download_files_error') do
        expect(-> { described_class.download_files }).
          to raise_error(Lokalise::Error::BadRequest, /Invalid `project_id` parameter/)
      end
    end
  end

  describe '.import!' do
    it 'halts when the API key is not set' do
      allow(LokaliseRails).to receive(:api_token).and_return(nil)
      expect(-> { described_class.import! }).to raise_error(LokaliseRails::Error, /API token is not set/i)
      expect(LokaliseRails).to have_received(:api_token)
      expect(count_translations).to eq(0)
    end

    it 'halts when the project_id is not set' do
      allow_project_id nil do
        expect(-> { described_class.import! }).to raise_error(LokaliseRails::Error, /ID is not set/i)
        expect(count_translations).to eq(0)
      end
    end
  end
end
