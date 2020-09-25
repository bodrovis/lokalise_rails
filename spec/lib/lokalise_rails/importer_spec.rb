# frozen_string_literal: true

describe LokaliseRails::Importer do
  describe '.download_files' do
    it 'returns a proper download URL' do
      response = VCR.use_cassette('download_files') do
        described_class.download_files
      end

      expect(response['project_id']).to eq('189934715f57a162257d74.88352370')
      expect(response['bundle_url']).to include('s3-eu-west-1.amazonaws.com')
    end
  end
end