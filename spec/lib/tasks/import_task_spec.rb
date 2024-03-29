# frozen_string_literal: true

RSpec.describe 'Import Rake task' do
  let(:global_config) { LokaliseRails::GlobalConfig }
  let(:loc_path) { global_config.locales_path }

  it 'halts when the API key is not set' do
    allow(global_config).to receive(:api_token).and_return(nil)

    expect { Rake::Task['lokalise_rails:import'].execute }.to raise_error(SystemExit, /API token is not set/i)
    expect(global_config).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow(global_config).to receive(:project_id).and_return(nil)

    expect { Rake::Task['lokalise_rails:import'].execute }.to raise_error(SystemExit, /ID is not set/i)

    expect(global_config).to have_received(:project_id)
  end

  context 'when directory is empty' do
    before do
      mkdir_locales
      rm_translation_files
    end

    after do
      rm_translation_files
    end

    describe 'import' do
      it 'is callable' do
        allow_project_id global_config, ENV.fetch('LOKALISE_PROJECT_ID', nil) do
          fake_bundle = "#{Dir.getwd}/spec/fixtures/trans.zip"

          stub_request(:post, 'https://api.lokalise.com/api2/projects/672198945b7d72fc048021.15940510/files/download').
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
              body: JSON.dump({
                                project_id: '672198945b7d72fc048021.15940510',
                                bundle_url: fake_bundle
                              })
            )

          expect { Rake::Task['lokalise_rails:import'].execute }.to output(/complete!/).to_stdout

          expect(count_translations).to eq(4)

          expect_file_exist loc_path, 'en/nested/main_en.yml'
          expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
          expect_file_exist loc_path, 'ru/main_ru.yml'
        end
      end

      it 're-raises export errors' do
        allow_project_id global_config, 'fake' do
          stub_request(:post, 'https://api.lokalise.com/api2/projects/fake/files/download').
            to_return(
              status: 400,
              body: '{"error":{"message":"Invalid `project_id` parameter","code":400}}'
            )

          expect do
            Rake::Task['lokalise_rails:import'].execute
          end.to raise_error(SystemExit, /Invalid `project_id` parameter/)
        end
      end
    end
  end
end
