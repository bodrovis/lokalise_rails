# frozen_string_literal: true

describe LokaliseRails::Utils do
  describe '.rails_root' do
    it 'returns RAILS_ROOT if defined' do
      allow(Rails).to receive(:root).and_return(nil)
      stub_const('RAILS_ROOT', '/stub')
      expect(described_class.rails_root).to eq('/stub')
    end

    it 'fallbacks if neither roots are present' do
      allow(Rails).to receive(:root).and_return(nil)
      expect(described_class.rails_root).to be_nil
    end
  end
end
