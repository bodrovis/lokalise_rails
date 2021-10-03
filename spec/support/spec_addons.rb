# frozen_string_literal: true

module SpecAddons
  def allow_project_id(obj, value = '189934715f57a162257d74.88352370')
    allow(obj.global_opts).to receive(:project_id).and_return(value)
    return unless block_given?

    yield
    expect(obj.global_opts).to have_received(:project_id)
  end

  def allow_task_def_instance(klass, instance)
    allow(klass).to receive(:new).and_return(instance)
  end
end
