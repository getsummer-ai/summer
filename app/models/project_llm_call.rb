# frozen_string_literal: true

class ProjectLlmCall < ApplicationRecord
  belongs_to :project
  belongs_to :initializer, polymorphic: true

  # @param [ProjectArticle] model
  # @param [Hash] attributes
  def self.save_summary_call!(model, attributes = {})
    ProjectLlmCall.create!(
      project_id: model.project_id,
      initializer: model,
      feature: 'summary',
      **attributes,
    )
  end

  # @param [ProjectArticle] model
  # @param [Hash] attributes
  def self.save_products_call!(model, attributes = {})
    ProjectLlmCall.create!(
      project_id: model.project_id,
      initializer: model,
      feature: 'products',
      **attributes,
    )
  end
end

# == Schema Information
#
# Table name: project_llm_calls
#
#  id               :bigint           not null, primary key
#  feature          :enum             default("default"), not null
#  in_tokens_count  :integer          default(0), not null
#  info             :jsonb            not null
#  initializer_type :string
#  input            :text
#  llm              :enum             not null
#  out_tokens_count :integer          default(0), not null
#  output           :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  initializer_id   :bigint
#  project_id       :bigint           not null
#
# Indexes
#
#  idx_on_initializer_type_initializer_id_feature_f0de9640c3  (initializer_type,initializer_id,feature)
#  index_project_llm_calls_on_initializer                     (initializer_type,initializer_id)
#  index_project_llm_calls_on_project_id                      (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#
