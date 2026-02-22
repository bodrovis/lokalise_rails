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
      allow(fake_class).to receive(:additional_client_opts=).with(duck_type(:each))
      fake_class.additional_client_opts = {
        open_timeout: 100,
        timeout: 500
      }
      expect(fake_class).to have_received(:additional_client_opts=)
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
      cond = lambda(&:nil?)
      allow(fake_class).to receive(:skip_file_export=).with(cond)
      fake_class.skip_file_export = cond
      expect(fake_class).to have_received(:skip_file_export=)
    end

    it 'is possible to set translations_loader' do
      runner = lambda(&:to_json)
      allow(fake_class).to receive(:translations_loader=).with(runner)
      fake_class.translations_loader = runner
      expect(fake_class).to have_received(:translations_loader=)
    end

    it 'is possible to set translations_converter' do
      runner = lambda(&:to_json)
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

    it 'is possible to disable the export task' do
      allow(fake_class).to receive(:disable_export_task=).with(true)
      fake_class.disable_export_task = true
      expect(fake_class).to have_received(:disable_export_task=)
    end

    it 'is possible to disable the import task' do
      allow(fake_class).to receive(:disable_import_task=).with(true)
      fake_class.disable_import_task = true
      expect(fake_class).to have_received(:disable_import_task=)
    end
  end

  describe '.for_project' do
    let(:cfg) { Class.new(described_class) }

    before { cfg.projects.clear }
    after  { cfg.projects.clear }

    it 'supports registering multiple named projects' do
      cfg.for_project(:mobile) { |c| c.project_id = 'mobile.123' }
      cfg.for_project(:admin)  { |c| c.project_id = 'admin.456' }

      expect(cfg.projects.keys).to contain_exactly(:mobile, :admin)
    end

    it 'registers a named project with the given settings' do
      cfg.for_project(:mobile) do |c|
        c.project_id = 'mobile_id.123'
        c.locales_path = '/config/locales/mobile'
      end

      expect(cfg.projects[:mobile]).to eq(
        project_id: 'mobile_id.123',
        locales_path: '/config/locales/mobile'
      )
    end

    it 'stores an empty hash when no block is given' do
      cfg.for_project(:empty)

      expect(cfg.projects[:empty]).to eq({})
    end

    it 'accepts lambda values such as skip_file_export' do
      filter = ->(file) { file.include?('fr') }
      cfg.for_project(:mobile) { |c| c.skip_file_export = filter }

      expect(cfg.projects[:mobile][:skip_file_export]).to eq(filter)
    end

    it 'does not leak settings into GlobalConfig' do
      cfg.for_project(:mobile) { |c| c.project_id = 'mobile.123' }

      expect(cfg.project_id).not_to eq('mobile.123')
    end

    it 'raises NoMethodError when calling a getter (non-setter) in the block' do
      expect { cfg.for_project(:mobile, &:project_id) }.to raise_error(NoMethodError)
    end

    it 'responds to setter methods but not to getter methods' do
      cfg.for_project(:mobile) do |c|
        expect(c.respond_to?(:project_id=)).to be true
        expect(c.respond_to?(:project_id)).to be false
      end
    end

    it 'raises when an unknown config key is provided' do
      expect do
        cfg.for_project(:mobile) { |c| c.projet_id = 'oops' }
      end.to raise_error(ArgumentError, /Unknown config key/i)
    end

    it 'does not respond to unknown setters' do
      cfg.for_project(:mobile) do |c|
        expect(c.respond_to?(:project_id=)).to be true
        expect(c.respond_to?(:projet_id=)).to be false # sic!
      end
    end
  end

  describe '.for_default_project' do
    let(:cfg) { Class.new(described_class) }

    before { cfg.default_project.clear }
    after  { cfg.default_project.clear }

    it 'stores default project overrides and returns the merged hash' do
      result = cfg.for_default_project do |c|
        c.project_id = 'default.123'
        c.locales_path = '/config/locales/default'
      end

      expect(result).to eq(
        project_id: 'default.123',
        locales_path: '/config/locales/default'
      )
      expect(cfg.default_project).to eq(result)
      expect(cfg.project_opts(:default)).to eq(result)
    end

    it 'merges settings across multiple calls (does not replace)' do
      cfg.for_default_project { |c| c.project_id = 'default.123' }
      cfg.for_default_project { |c| c.locales_path = '/config/locales/default' }

      expect(cfg.project_opts(:default)).to eq(
        project_id: 'default.123',
        locales_path: '/config/locales/default'
      )
    end

    it 'stores an empty hash when no block is given' do
      expect(cfg.for_default_project).to eq({})
      expect(cfg.project_opts(:default)).to eq({})
    end

    it 'does not leak settings into GlobalConfig setters' do
      cfg.project_id = 'global.999'

      cfg.for_default_project { |c| c.project_id = 'default.123' }

      expect(cfg.project_id).to eq('global.999')
      expect(cfg.project_opts(:default)[:project_id]).to eq('default.123')
    end

    it 'raises when an unknown config key is provided' do
      expect do
        cfg.for_default_project { |c| c.projet_id = 'oops' } # sic!
      end.to raise_error(ArgumentError, /Unknown config key/i)
    end

    it 'does not respond to unknown setters' do
      cfg.for_default_project do |c|
        expect(c.respond_to?(:project_id=)).to be true
        expect(c.respond_to?(:projet_id=)).to be false # sic!
      end
    end
  end
end
