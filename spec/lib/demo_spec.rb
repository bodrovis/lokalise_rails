RSpec.describe 'test' do
  it 'should work' do
    #puts Rails.root
    Dummy::Application.load_tasks
    Rake::Task['lokalise_rails:import'].invoke
    #Rails::Generators.invoke 'lokalise_rails:install'
  end
end
