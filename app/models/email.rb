# frozen_string_literal: true
#
class Email < ApplicationRecord
  # TODO: Brakes creating new emails with emails_emailables models
  # include PassiveColumns
  # passive_columns :mail

  has_many :email_related_models, dependent: :destroy
  accepts_nested_attributes_for :email_related_models

  validates :from, presence: true

  # Get relation of all emails for a model.
  # @param [ActiveRecord::Base] model any ActiveRecord model
  # @return [Email::ActiveRecord_Relation] all emails for a model
  def self.emails_for(model)
    Email.joins(:email_related_models).where(email_related_models: { model: })
  end

  # If email reached mail server. Status should present and not be an error.
  # @return [Boolean] true if email was delivered
  def delivered?
    status.present? && status != 'error'
  end

  # Initialize mail message from a stored encoded text.
  # @return [Mail::Message] mail message
  def message
    Mail::Message.new mail
  end

  # Get HTML or text body of email.
  # @return [String, nil] mail body string or `nil` if mail doesn't have html body
  def to_html
    return message.html_part.decoded if message.html_part
    message.decoded if message.mime_type == 'text/html'
  end
end

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: emails
#
#  id              :uuid             not null, primary key
#  action_name     :string
#  delivery_method :string
#  from            :string
#  mail            :text
#  mailer_name     :string
#  retries         :integer          default(0)
#  sent_at         :datetime
#  subject         :string
#  to              :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  message_id      :string
#
# Indexes
#
#  index_emails_on_created_at  (created_at)
#  index_emails_on_message_id  (message_id)
#
