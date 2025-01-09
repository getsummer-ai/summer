# frozen_string_literal: true
#
# Module for Email model extensions.
#
module Emails
  #
  # If persist emails in database.
  #
  # @return [Boolean] true if emails should be stored in database
  #
  def self.store?
    true
  end
end
