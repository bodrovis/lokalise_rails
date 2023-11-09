# frozen_string_literal: true

describe LokaliseRails::GlobalConfig do
  let(:child_config) { Class.new(described_class) }

  it 'is possible to provide config options' do
    described_class.config do |c|
      expect(c).to eq(described_class)
    end
  end

  it 'can be redefined' do
    child_config.config do |c|
      c.api_token = ENV.fetch('LOKALISE_API_TOKEN', nil)
      c.project_id = ENV.fetch('LOKALISE_PROJECT_ID', nil)

      c.branch = 'develop'
    end

    expect(child_config.branch).to eq('develop')
    importer = LokaliseManager::TaskDefinitions::Importer.new({}, child_config)
    expect(importer.config.branch).to eq('develop')
    expect(importer.config.api_token).to eq(ENV.fetch('LOKALISE_API_TOKEN', nil))
  end

  describe 'parameters' do
    let(:fake_class) { class_double(described_class) }

    it 'is possible to set project_id' do
      allow(fake_class).to receive(:project_id=).with('123.abc')
      fake_class.project_id = '123.abc'
      expect(fake_class).to have_received(:project_id=)
    end

    it 'is possible to set raise_on_export_fail' do
      allow(fake_class).to receive(:raise_on_export_fail=).with(false)
      fake_class.raise_on_export_fail = false
      expect(fake_class).to have_received(:raise_on_export_fail=)
    end

    it 'is possible to set silent_mode' do
      allow(fake_class).to receive(:silent_mode=).with(true)
      fake_class.silent_mode = true
      expect(fake_class).to have_received(:silent_mode=)
    end

    it 'is possible to set use_oauth2_token' do
      allow(fake_class).to receive(:use_oauth2_token=).with(true)
      fake_class.use_oauth2_token = true
      expect(fake_class).to have_received(:use_oauth2_token=)
    end

    it 'is possible to set file_ext_regexp' do
      allow(fake_class).to receive(:file_ext_regexp=).with(Regexp.new('.*'))
      fake_class.file_ext_regexp = Regexp.new('.*')
      expect(fake_class).to have_received(:file_ext_regexp=)
    end

    it 'is possible to set import_opts' do
      allow(fake_class).to receive(:import_opts=).with(duck_type(:each))
      fake_class.import_opts = {
        format: 'json',
        indentation: '8sp'
      }
      expect(fake_class).to have_received(:import_opts=)
    end

    it 'is possible to set export_opts' do
      allow(fake_class).to receive(:export_opts=).with(duck_type(:each))
      fake_class.export_opts = {
        convert_placeholders: true,
        detect_icu_plurals: true
      }
      expect(fake_class).to have_received(:export_opts=)
    end

    it 'is possible to set branch' do
      allow(fake_class).to receive(:branch=).with('custom')
      fake_class.branch = 'custom'
      expect(fake_class).to have_received(:branch=)
    end

    it 'is possible to set timeouts' do
      allow(fake_class).to receive(:timeouts=).with(duck_type(:each))
      fake_class.timeouts = {
        open_timeout: 100,
        timeout: 500
      }
      expect(fake_class).to have_received(:timeouts=)
    end

    it 'is possible to set import_safe_mode' do
      allow(fake_class).to receive(:import_safe_mode=).with(true)
      fake_class.import_safe_mode = true
      expect(fake_class).to have_received(:import_safe_mode=)
    end

    it 'is possible to set max_retries_export' do
      allow(fake_class).to receive(:max_retries_export=).with(10)
      fake_class.max_retries_export = 10
      expect(fake_class).to have_received(:max_retries_export=)
    end

    it 'is possible to set max_retries_import' do
      allow(fake_class).to receive(:max_retries_import=).with(10)
      fake_class.max_retries_import = 10
      expect(fake_class).to have_received(:max_retries_import=)
    end

    it 'is possible to set api_token' do
      allow(fake_class).to receive(:api_token=).with('abc')
      fake_class.api_token = 'abc'
      expect(fake_class).to have_received(:api_token=)
    end

    it 'is possible to override locales_path' do
      allow(fake_class).to receive(:locales_path=).with('/demo/path')
      fake_class.locales_path = '/demo/path'
      expect(fake_class).to have_received(:locales_path=)
    end

    it 'is possible to set skip_file_export' do
      cond = ->(f) { f.nil? }
      allow(fake_class).to receive(:skip_file_export=).with(cond)
      fake_class.skip_file_export = cond
      expect(fake_class).to have_received(:skip_file_export=)
    end

    it 'is possible to set translations_loader' do
      runner = ->(f) { f.to_json }
      allow(fake_class).to receive(:translations_loader=).with(runner)
      fake_class.translations_loader = runner
      expect(fake_class).to have_received(:translations_loader=)
    end

    it 'is possible to set translations_converter' do
      runner = ->(f) { f.to_json }
      allow(fake_class).to receive(:translations_converter=).with(runner)
      fake_class.translations_converter = runner
      expect(fake_class).to have_received(:translations_converter=)
    end

    it 'is possible to set lang_iso_inferer' do
      runner = ->(f, _path) { f.to_json }
      allow(fake_class).to receive(:lang_iso_inferer=).with(runner)
      fake_class.lang_iso_inferer = runner
      expect(fake_class).to have_received(:lang_iso_inferer=)
    end
  end
end
