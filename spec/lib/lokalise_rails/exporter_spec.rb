describe LokaliseRails::TaskDefinition::Exporter do
  before :all do
    add_translation_files!
  end

  after :all do
    rm_translation_files
  end

  describe '.export!' do
    it 'works' do
      VCR.use_cassette('upload_files') do
        described_class.export!
      end
    end
  end
end
