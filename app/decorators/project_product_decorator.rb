# frozen_string_literal: true
class ProjectProductDecorator < Draper::Decorator
  delegate_all

  def data_for_summary_app
    model.attributes.slice 'uuid', 'name', 'link', 'icon'
  end
end
