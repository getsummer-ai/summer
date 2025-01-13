# frozen_string_literal: true
# Email and its associations join model
class EmailRelatedModel < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :email
end

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: email_related_models
#
#  id         :bigint           not null, primary key
#  model_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  email_id   :uuid             not null
#  model_id   :string
#
# Indexes
#
#  index_email_related_models_on_email_id  (email_id)
#  index_emails_emailables_on_emailable    (model_type,model_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_id => emails.id) ON DELETE => cascade ON UPDATE => cascade
#
