# frozen_string_literal: true

module SpecAddons
  def allow_project_id(value = '189934715f57a162257d74.88352370')
    allow(LokaliseRails).to receive(:project_id).
      and_return(value)
  end
end
