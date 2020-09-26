# frozen_string_literal: true

describe LokaliseRails::TaskDefinition::Importer do
  describe '.download_files' do
    it 'returns a proper download URL' do
      response = VCR.use_cassette('download_files') do
        described_class.download_files
      end

      expect(response['project_id']).to eq('189934715f57a162257d74.88352370')
      expect(response['bundle_url']).to include('s3-eu-west-1.amazonaws.com')
    end
  end

  describe '.import!' do
    it 'halts when the API key is not set' do
      expect(LokaliseRails).to receive(:api_token).and_return(nil)
      result = described_class.import!
      expect(result).to include('API token is not set')
      expect(count_translations).to eq(0)
    end

    it 'halts when the project_id is not set' do
      expect(LokaliseRails).to receive(:project_id).and_return(nil)
      result = described_class.import!
      expect(result).to include('Project ID is not set')
      expect(count_translations).to eq(0)
    end
  end
end
