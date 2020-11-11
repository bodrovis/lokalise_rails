# frozen_string_literal: true

module SpecAddons
  def allow_project_id(value = ENV['LOKALISE_PROJECT_ID'])
    allow(LokaliseRails).to receive(:project_id).and_return(value)
    return unless block_given?

    yield
    expect(LokaliseRails).to have_received(:project_id)
  end
end
