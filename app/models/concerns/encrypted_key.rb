# frozen_string_literal: true

module EncryptedKey
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
