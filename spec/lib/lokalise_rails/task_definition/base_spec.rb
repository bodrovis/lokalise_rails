# frozen_string_literal: true

describe LokaliseRails::TaskDefinition::Base do
  specify '.reset_client!' do
    expect(described_class.api_client).to be_an_instance_of(Lokalise::Client)
    described_class.reset_api_client!
    current_client = described_class.instance_variable_get '@api_client'
    expect(current_client).to be_nil
  end

  specify '.project_id_with_branch!' do
    result = described_class.send :project_id_with_branch
    expect(result).to be_an_instance_of(String)
    expect(result).to include(':master')
  end

  describe '.subdir_and_filename_for' do
    it 'works properly for longer paths' do
      path = 'my_path/is/here/file.yml'
      result = described_class.send(:subdir_and_filename_for, path)
      expect(result.length).to eq(2)
      expect(result[0]).to be_an_instance_of(Pathname)
      expect(result[0].to_s).to eq('my_path/is/here')
      expect(result[1].to_s).to eq('file.yml')
    end

    it 'works properly for shorter paths' do
      path = 'file.yml'
      result = described_class.send(:subdir_and_filename_for, path)
      expect(result.length).to eq(2)
      expect(result[1]).to be_an_instance_of(Pathname)
      expect(result[0].to_s).to eq('.')
      expect(result[1].to_s).to eq('file.yml')
    end
  end

  describe '.opt_errors' do
    it 'returns an error when the API key is not set' do
      allow(LokaliseRails).to receive(:api_token).and_return(nil)
      errors = described_class.opt_errors

      expect(LokaliseRails).to have_received(:api_token)
      expect(errors.length).to eq(1)
      expect(errors.first).to include('API token is not set')
    end

    it 'returns an error when the project_id is not set' do
      allow(LokaliseRails).to receive(:project_id).and_return(nil)
      errors = described_class.opt_errors

      expect(LokaliseRails).to have_received(:project_id)
      expect(errors.length).to eq(1)
      expect(errors.first).to include('Project ID is not set')
    end
  end

  describe '.proper_ext?' do
    it 'works properly with path represented as a string' do
      path = 'my_path/here/file.yml'
      expect(described_class.send(:proper_ext?, path)).to be true
    end

    it 'works properly with path represented as a pathname' do
      path = Pathname.new 'my_path/here/file.json'
      expect(described_class.send(:proper_ext?, path)).to be false
    end
  end

  describe '.api_client' do
    before(:all) { described_class.reset_api_client! }

    after(:all) { described_class.reset_api_client! }

    it 'is possible to set timeouts' do
      allow(LokaliseRails).to receive(:timeouts).and_return({
                                                              open_timeout: 100,
                                                              timeout: 500
                                                            })

      expect(described_class.api_client).to be_an_instance_of(Lokalise::Client)
      expect(described_class.api_client.open_timeout).to eq(100)
      expect(described_class.api_client.timeout).to eq(500)
    end
  end
end
