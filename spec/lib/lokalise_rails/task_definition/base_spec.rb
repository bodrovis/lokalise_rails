# frozen_string_literal: true

describe LokaliseRails::TaskDefinition::Base do
  let(:described_object) { described_class.new }

  describe '.initialize' do
    it 'options can be overridden' do
      obj = described_class.new token: 'fake'
      expect(obj.global_opts.token).to eq('fake')
    end
  end

  specify '.reset_client!' do
    expect(described_object.api_client).to be_an_instance_of(Lokalise::Client)
    described_object.reset_api_client!
    current_client = described_object.instance_variable_get '@api_client'
    expect(current_client).to be_nil
  end

  specify '.project_id_with_branch!' do
    result = described_object.send :project_id_with_branch
    expect(result).to be_an_instance_of(String)
    expect(result).to include(':master')
  end

  describe '.subdir_and_filename_for' do
    it 'works properly for longer paths' do
      path = 'my_path/is/here/file.yml'
      result = described_object.send(:subdir_and_filename_for, path)
      expect(result.length).to eq(2)
      expect(result[0]).to be_an_instance_of(Pathname)
      expect(result[0].to_s).to eq('my_path/is/here')
      expect(result[1].to_s).to eq('file.yml')
    end

    it 'works properly for shorter paths' do
      path = 'file.yml'
      result = described_object.send(:subdir_and_filename_for, path)
      expect(result.length).to eq(2)
      expect(result[1]).to be_an_instance_of(Pathname)
      expect(result[0].to_s).to eq('.')
      expect(result[1].to_s).to eq('file.yml')
    end
  end

  describe '.check_options_errors!' do
    it 'raises an error when the API key is not set' do
      allow(LokaliseRails).to receive(:api_token).and_return(nil)

      expect(-> { described_object.send(:check_options_errors!) }).to raise_error(LokaliseRails::Error, /API token is not set/i)

      expect(LokaliseRails).to have_received(:api_token)
    end

    it 'returns an error when the project_id is not set' do
      allow_project_id described_object, nil do
        expect(-> { described_object.send(:check_options_errors!) }).to raise_error(LokaliseRails::Error, /ID is not set/i)
      end
    end
  end

  describe '.proper_ext?' do
    it 'works properly with path represented as a string' do
      path = 'my_path/here/file.yml'
      expect(described_object.send(:proper_ext?, path)).to be true
    end

    it 'works properly with path represented as a pathname' do
      path = Pathname.new 'my_path/here/file.json'
      expect(described_object.send(:proper_ext?, path)).to be false
    end
  end

  describe '.api_client' do
    it 'is possible to set timeouts' do
      allow(described_object.global_opts).to receive(:timeouts).and_return({
                                                              open_timeout: 100,
                                                              timeout: 500
                                                            })

      expect(described_object.api_client).to be_an_instance_of(Lokalise::Client)
      expect(described_object.api_client.open_timeout).to eq(100)
      expect(described_object.api_client.timeout).to eq(500)
    end
  end
end
