RSpec.describe LokaliseRails do
  it 'runs export rake task properly' do
    expect(export_executor).to output(/complete!/).to_stdout
  end
end
