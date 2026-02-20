# frozen_string_literal: true

RSpec.describe 'Multi-project Rake tasks' do
  let(:global_config) { LokaliseRails::GlobalConfig }
  let(:project_id) { ENV.fetch('LOKALISE_PROJECT_ID', nil) }

  describe 'auto-generated export task' do
    context 'with translation files' do
      before { add_translation_files! with_ru: true }
      after  { rm_translation_files }

      it 'runs successfully' do
        stub_request(:post, "https://api.lokalise.com/api2/projects/#{project_id}/files/upload").
          to_return(
            status: 200,
            body: JSON.dump({
                              project_id: project_id,
                              branch: 'master',
                              process: {
                                process_id: 'abc123def456',
                                type: 'file-import',
                                status: 'queued',
                                message: '',
                                created_by: 20_181,
                                created_by_email: 'test@example.com',
                                created_at: '2024-01-01 00:00:00 (Etc/UTC)',
                                created_at_timestamp: 1_704_067_200
                              }
                            })
          )

        expect { Rake::Task['lokalise_rails:dummy_project:export'].execute }.to output(/complete!/).to_stdout
      end

      it 're-raises export errors' do
        stub_request(:post, "https://api.lokalise.com/api2/projects/#{project_id}/files/upload").
          to_return(
            status: 400,
            body: JSON.dump({error: {message: 'Unknown `lang_iso`', code: 400}})
          )

        expect { Rake::Task['lokalise_rails:dummy_project:export'].execute }.
          to raise_error(SystemExit, /Unknown `lang_iso`/)
      end
    end
  end

  describe 'auto-generated import task' do
    context 'when the locales directory is empty' do
      before do
        mkdir_locales
        rm_translation_files
      end

      after { rm_translation_files }

      it 'runs successfully' do
        fake_bundle = "#{Dir.getwd}/spec/fixtures/trans.zip"

        stub_request(:post, "https://api.lokalise.com/api2/projects/#{project_id}/files/download").
          with(
            body: JSON.dump({
                              format: 'ruby_yaml',
                              placeholder_format: 'icu',
                              yaml_include_root: true,
                              original_filenames: true,
                              directory_prefix: '',
                              indentation: '2sp'
                            })
          ).
          to_return(
            status: 200,
            body: JSON.dump({project_id: project_id, bundle_url: fake_bundle})
          )

        expect { Rake::Task['lokalise_rails:dummy_project:import'].execute }.to output(/complete!/).to_stdout
      end

      it 're-raises import errors' do
        stub_request(:post, "https://api.lokalise.com/api2/projects/#{project_id}/files/download").
          to_return(
            status: 400,
            body: '{"error":{"message":"Invalid `project_id` parameter","code":400}}'
          )

        expect { Rake::Task['lokalise_rails:dummy_project:import'].execute }.
          to raise_error(SystemExit, /Invalid `project_id` parameter/)
      end
    end
  end

  describe 'for_project registration' do
    after { global_config.projects.delete(:secondary) }

    it 'registers a named project with the given settings' do
      global_config.for_project(:secondary) do |c|
        c.project_id = '542886116159f798720dc4.94769464'
        c.locales_path = "#{Rails.root}/config/locales/secondary"
      end

      expect(global_config.projects[:secondary]).to eq(
        project_id: '542886116159f798720dc4.94769464',
        locales_path: "#{Rails.root}/config/locales/secondary"
      )
    end

    it 'supports registering multiple named projects' do
      global_config.for_project(:secondary) { |c| c.project_id = 'aaa.111' }
      global_config.for_project(:tertiary) { |c| c.project_id = 'bbb.222' }

      expect(global_config.projects.keys).to include(:secondary, :tertiary)
    ensure
      global_config.projects.delete(:tertiary)
    end

    it 'stores an empty hash when no block is given' do
      global_config.for_project(:secondary)

      expect(global_config.projects[:secondary]).to eq({})
    end

    it 'accepts lambda values such as skip_file_export' do
      filter = ->(file) { file.include?('fr') }
      global_config.for_project(:secondary) { |c| c.skip_file_export = filter }

      expect(global_config.projects[:secondary][:skip_file_export]).to eq(filter)
    end

    it 'does not leak settings into GlobalConfig' do
      global_config.for_project(:secondary) { |c| c.project_id = 'secondary.123' }

      expect(global_config.project_id).not_to eq('secondary.123')
    end
  end

  describe 'settings inheritance' do
    let(:secondary_id) { '542886116159f798720dc4.94769464' }
    let(:secondary_locales_path) { "#{Rails.root}/config/locales/secondary" }

    after { global_config.projects.delete(:secondary) }

    it 'falls back to GlobalConfig api_token when not set in the project block' do
      global_config.for_project(:secondary) { |c| c.project_id = secondary_id }

      opts = global_config.projects[:secondary]
      expect(opts).not_to have_key(:api_token)

      importer = LokaliseManager.importer(opts, global_config)
      expect(importer.config.api_token).to eq(global_config.api_token)
    end

    it 'uses the project-specific locales_path when set' do
      global_config.for_project(:secondary) do |c|
        c.project_id = secondary_id
        c.locales_path = secondary_locales_path
      end

      opts = global_config.projects[:secondary]
      importer = LokaliseManager.importer(opts, global_config)
      expect(importer.config.locales_path).to eq(secondary_locales_path)
    end
  end
end
