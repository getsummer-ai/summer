# frozen_string_literal: true
#
module Emails
  #
  # Creates or updates +Email+ model from +ActionMailer+ mail message.
  # Emails have associated models stored in +emailables+ association.
  #
  class Updater
    attr_accessor :email, :message, :result, :errors

    # @param [Mail::Message] message mail message used to create Email
    def initialize(message)
      @message = message
    end

    def call
      id = retrieve_header('X-SM-Email-Id')

      attrs = main_attributes
      if id.present?
        @email = Email.find(id).tap { |e| e.update attrs }
      else
        Rails.logger.debug retrieve_header('X-SM-Emailables').to_sentence
        attrs[:emails_emailables_attributes] = retrieve_header('X-SM-Emailables').presence || []
        @email = Email.create(attrs)
      end

      return unless @email.errors.any?
      raise "Unable to save email instance: #{@email.errors.full_messages.to_sentence}"
      # Rails.logger.error("Unable to save email instance: #{@email.errors.full_messages.to_sentence}")
      # Rails.logger.error(@email.attributes.as_json)
      # Rails.logger.error(exception.backtrace.select { |path| path.match?(%r{/app/}) })
    end

    private

      def main_attributes
        {
          message_id: @message.message_id,
          to: @message.header[:to],
          from: @message.header[:from],
          subject: @message.subject,
          mail: @message.encoded.gsub("=\n", ''),
          delivery_method: ActionMailer::Base.delivery_methods.key(@message.delivery_method.class),
          sent_at: Time.now.utc,
          mailer_name: retrieve_header('X-SM-MailerName'),
          action_name: retrieve_header('X-SM-ActionName')
        }
      end

      def retrieve_header(header)
        return unless @message[header]
        @message[header].unparsed_value
      end
  end
end
