# frozen_string_literal: true

module EncryptedKey
  extend ActiveSupport::Concern

  included do
    def self.decrypt_id(id) = BasicEncrypting.decode(id)
  end

  def to_param
    encrypted_id
  end

  def to_key
    key = encrypted_id
    Array(key) if key
  end

  def encrypted_id
    return nil if id.nil?
    @encrypted_id ||= BasicEncrypting.encode(id)
  end
end
