require 'fileutils'

RSpec.describe 'Import task' do
  before do
    Dummy::Application.load_tasks
    task.reenable
  end

  after do
    Rake::Task.clear
  end

  let(:task) { Rake::Task['lokalise_rails:import'] }

  context 'directory is empty' do
    before do
      FileUtils.mkdir_p(LokaliseRails.loc_path) unless File.directory?(LokaliseRails.loc_path)
      FileUtils.rm_rf Dir["#{LokaliseRails.loc_path}/*"]
    end

    after :all do
      FileUtils.rm_rf Dir["#{LokaliseRails.loc_path}/*"]
    end

    it 'is callable' do
      expect(LokaliseRails::Importer).to receive(:download_files).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => "#{Rails.root}/public/translations.zip"
        }
      )

      expect(-> {
        task.invoke
      }).to output('Task complete!').to_stdout

      file_count = Dir["#{Rails.root}/config/locales/*"].count do |file|
        File.file?(file)
      end
      expect(file_count).to eq(4)

      main_en = File.join LokaliseRails.loc_path, 'main_en.yml'
      expect(File.file?(main_en)).to be true
    end
  end

  context 'directory is not empty' do
    before :all do
      FileUtils.mkdir_p(LokaliseRails.loc_path) unless File.directory?(LokaliseRails.loc_path)
      FileUtils.rm_rf Dir["#{LokaliseRails.loc_path}/*"]
      temp_file = File.join LokaliseRails.loc_path, 'kill.me'
      File.open(temp_file, 'w+') { |file| file.write('temp') }
      LokaliseRails.import_safe_mode = true
    end

    after :all do
      FileUtils.rm_rf Dir["#{LokaliseRails.loc_path}/*"]
      LokaliseRails.import_safe_mode = false
    end

    it 'returns a success message with default settings' do
      expect(LokaliseRails::Importer).to receive(:download_files).and_return(
        {
          'project_id' => '123.abc',
          'bundle_url' => "#{Rails.root}/public/translations.zip"
        }
      )
      expect($stdin).to receive(:gets).and_return('Y')
      expect(-> { task.invoke }).
        to output(
          "The target directory #{LokaliseRails.loc_path} is not empty!\nEnter Y to continue: Task complete!"
        ).to_stdout

      file_count = Dir["#{LokaliseRails.loc_path}/*"].count { |file| File.file?(file) }
      expect(file_count).to eq(5)
    end
  end
end
