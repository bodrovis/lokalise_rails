# frozen_string_literal: true

describe LokaliseRails do
  it 'returns a proper version' do
    expect(LokaliseRails::VERSION).to be_a(String)
  end

  it 'is possible to provide config options' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end

  describe 'parameters' do
    let(:fake_class) { class_double('LokaliseRails') }

    it 'is possible to set project_id' do
      allow(fake_class).to receive(:project_id=).with('123.abc')
      fake_class.project_id = '123.abc'
    end

    it 'is possible to set file_ext_regexp' do
      allow(fake_class).to receive(:file_ext_regexp=).with(Regexp.new('.*'))
      fake_class.file_ext_regexp = Regexp.new('.*')
    end

    it 'is possible to set import_opts' do
      allow(fake_class).to receive(:import_opts=).with(duck_type(:each))
      fake_class.import_opts = {
        format: 'json',
        indentation: '8sp'
      }
    end

    it 'is possible to set export_opts' do
      allow(fake_class).to receive(:export_opts=).with(duck_type(:each))
      fake_class.export_opts = {
        convert_placeholders: true,
        detect_icu_plurals: true
      }
    end

    it 'is possible to set branch' do
      allow(fake_class).to receive(:branch=).with('custom')
      fake_class.branch = 'custom'
    end

    it 'is possible to set timeouts' do
      allow(fake_class).to receive(:timeouts=).with(duck_type(:each))
      fake_class.timeouts = {
        open_timeout: 100,
        timeout: 500
      }
    end

    it 'is possible to set import_safe_mode' do
      allow(fake_class).to receive(:import_safe_mode=).with(true)
      fake_class.import_safe_mode = true
    end

    it 'is possible to set max_retries_export' do
      allow(fake_class).to receive(:max_retries_export=).with(10)
      fake_class.max_retries_export = 10
    end

    it 'is possible to set max_retries_import' do
      allow(fake_class).to receive(:max_retries_import=).with(10)
      fake_class.max_retries_import = 10
    end

    it 'is possible to set api_token' do
      allow(fake_class).to receive(:api_token=).with('abc')
      fake_class.api_token = 'abc'
    end

    it 'is possible to override locales_path' do
      allow(fake_class).to receive(:locales_path=).with('/demo/path')
      fake_class.locales_path = '/demo/path'
    end

    it 'is possible to set skip_file_export' do
      cond = ->(f) { f.nil? }
      allow(fake_class).to receive(:skip_file_export=).with(cond)
      fake_class.skip_file_export = cond
    end

    it 'is possible to set translations_loader' do
      runner = ->(f) { f.to_json }
      allow(fake_class).to receive(:translations_loader=).with(runner)
      fake_class.translations_loader = runner
    end

    it 'is possible to set translations_converter' do
      runner = ->(f) { f.to_json }
      allow(fake_class).to receive(:translations_converter=).with(runner)
      fake_class.translations_converter = runner
    end

    it 'is possible to set lang_iso_inferer' do
      runner = ->(f) { f.to_json }
      allow(fake_class).to receive(:lang_iso_inferer=).with(runner)
      fake_class.lang_iso_inferer = runner
    end
  end
end
