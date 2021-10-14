# frozen_string_literal: true

module SpecAddons
  def expect_file_exist(path, file)
    file_path = File.join path, file
    expect(File.file?(file_path)).to be true
  end

  def allow_project_id(obj, value)
    allow(obj).to receive(:project_id).and_return(value)
    return unless block_given?

    yield
    expect(obj).to have_received(:project_id)
  end
end
