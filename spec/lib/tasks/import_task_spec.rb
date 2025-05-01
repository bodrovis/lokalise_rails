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
      let(:project_id) { ENV.fetch('LOKALISE_PROJECT_ID', nil) }

      it 'runs successfully' do
        allow_project_id global_config, project_id do
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
              body: JSON.dump({
                                project_id: project_id,
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

      it 'runs successfully in async mode' do
        process_id = '1efed57f-2720-6212-abd2-3e03040b6ae5'

        allow(global_config).to receive(:import_async).and_return(true)

        allow_project_id global_config, project_id do
          fake_bundle = "#{Dir.getwd}/spec/fixtures/trans.zip"

          stub_request(:post, "https://api.lokalise.com/api2/projects/#{project_id}/files/async-download").
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
                                process_id: process_id
                              })
            )

          stub_request(:get, "https://api.lokalise.com/api2/projects/#{project_id}/processes/#{process_id}").
            to_return(
              status: 200,
              body: JSON.dump({
                                process: {
                                  process_id: '1efed57f-2720-6212-abd2-3e03040b6ae5',
                                  type: 'async-export',
                                  status: 'finished',
                                  message: '',
                                  created_by: 20_181,
                                  created_by_email: 'bodrovis@protonmail.com',
                                  created_at: '2023-05-16 12:00:49 (Etc/UTC)',
                                  created_at_timestamp: 1_684_238_449,
                                  details: {
                                    file_size_kb: 1,
                                    total_number_of_keys: 4,
                                    download_url: fake_bundle
                                  }
                                }
                              })
            )

          expect { Rake::Task['lokalise_rails:import'].execute }.to output(/complete!/).to_stdout

          expect(count_translations).to eq(4)

          expect_file_exist loc_path, 'en/nested/main_en.yml'
          expect_file_exist loc_path, 'en/nested/deep/secondary_en.yml'
          expect_file_exist loc_path, 'ru/main_ru.yml'
        end

        expect(global_config).to have_received(:import_async)
      end

      it 'is not callable when disable_import_task is true' do
        allow(global_config).to receive_messages(disable_import_task: true, project_id: 'fake')
        expect do
          expect do
            Rake::Task['lokalise_rails:import'].execute
          end.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
        end.to output(/Import task is disabled\./).to_stdout
        expect(global_config).to have_received(:disable_import_task)
        expect(global_config).not_to have_received(:project_id)
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
