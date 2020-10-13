module SpecAddons
  def allow_project_id
    allow(LokaliseRails).to receive(:project_id).
    and_return('189934715f57a162257d74.88352370')
  end
end
