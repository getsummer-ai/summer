# frozen_string_literal: true
# Email and its associations join model
class EmailsEmailable < ApplicationRecord
  belongs_to :emailable, polymorphic: true
  belongs_to :email
end

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: emails_emailables
#
#  id             :bigint           not null, primary key
#  emailable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  email_id       :uuid             not null
#  emailable_id   :string
#
# Indexes
#
#  index_emails_emailables_on_email_id   (email_id)
#  index_emails_emailables_on_emailable  (emailable_type,emailable_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_id => emails.id) ON DELETE => cascade ON UPDATE => cascade
#
