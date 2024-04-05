# frozen_string_literal: true
class Project
  class ProjectAppearanceSettings
    include StoreModel::Model

    attribute :button_radius, :string, default: 'xl'
    attribute :frame_theme, :string, default: 'white'
    attribute :button_theme, :string, default: 'white'

    validates :button_radius, inclusion: { in: %w[xl sm] }
    validates :frame_theme, inclusion: { in: %w[black white] }
    validates :button_theme, inclusion: { in: %w[black white] }
  end
end
