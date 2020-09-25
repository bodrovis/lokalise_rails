# frozen_string_literal: true

describe LokaliseRails do
  describe 'parameters' do
    let(:fake_class) { class_double('LokaliseRails') }

    it 'is possible to set project_id' do
      expect(fake_class).to receive(:project_id=).with('123.abc')
      fake_class.project_id = '123.abc'
    end

    it 'is possible to set import_opts' do
      expect(fake_class).to receive(:import_opts=).with(duck_type(:each))
      fake_class.import_opts = {
        format: 'json',
        indentation: '8sp'
      }
    end

    it 'is possible to set import_safe_mode' do
      expect(fake_class).to receive(:import_safe_mode=).with(true)
      fake_class.import_safe_mode = true
    end

    it 'is possible to set api_token' do
      expect(fake_class).to receive(:api_token=).with('abc')
      fake_class.api_token = 'abc'
    end

    it 'is possible to override locales_path' do
      expect(fake_class).to receive(:locales_path).and_return('/demo/path')

      expect(fake_class.locales_path).to eq('/demo/path')
    end
  end
end