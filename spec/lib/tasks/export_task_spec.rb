# frozen_string_literal: true

RSpec.describe 'Export Rake task' do
  let(:global_config) { LokaliseRails::GlobalConfig }

  it 'halts when the API key is not set' do
    allow(global_config).to receive(:api_token).and_return(nil)

    expect { Rake::Task['lokalise_rails:export'].execute }.to raise_error(SystemExit, /API token is not set/i)
    expect(global_config).to have_received(:api_token)
  end

  it 'halts when the project ID is not set' do
    allow(global_config).to receive(:project_id).and_return(nil)

    expect { Rake::Task['lokalise_rails:export'].execute }.to raise_error(SystemExit, /ID is not set/i)

    expect(global_config).to have_received(:project_id)
  end

  context 'with two translation files' do
    before do
      add_translation_files! with_ru: true
    end

    after do
      rm_translation_files
    end

    describe 'export' do
      it 'is callable' do
        allow_project_id global_config, ENV.fetch('LOKALISE_PROJECT_ID', nil) do
          stub_request(:post, 'https://api.lokalise.com/api2/projects/672198945b7d72fc048021.15940510/files/upload').
            to_return(
              status: 200,
              body: JSON.dump({
                                project_id: '672198945b7d72fc048021.15940510',
                                branch: 'master',
                                process: {
                                  process_id: '1cab0ef1cd376687fcebd4bc266c44fd49bffe74',
                                  type: 'file-import',
                                  status: 'queued',
                                  message: '',
                                  created_by: 20_181,
                                  created_by_email: 'bodrovis@protonmail.com',
                                  created_at: '2022-01-27 17:39:17 (Etc/UTC)',
                                  created_at_timestamp: 1_643_305_157
                                }
                              })
            )

          expect { Rake::Task['lokalise_rails:export'].execute }.to output(/complete!/).to_stdout
        end
      end

      it 're-raises export errors' do
        allow_project_id global_config, '542886116159f798720dc4.94769464' do
          stub_request(:post, 'https://api.lokalise.com/api2/projects/542886116159f798720dc4.94769464/files/upload').
            to_return(
              status: 400,
              body: JSON.dump({error: {message: 'Unknown `lang_iso`', code: 400}})
            )

          expect { Rake::Task['lokalise_rails:export'].execute }.to raise_error(SystemExit, /Unknown `lang_iso`/)
        end
      end
    end
  end
end
