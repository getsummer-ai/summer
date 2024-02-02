# OpenStruct will serialize to json without table
module Hashing
  sqids = Sqids.new(
    alphabet: 'R90cIx6eVsuqWXSCyQlNKjF4vT5pP1rLYdZG2t7nBDzHofEMJa38gbhiAOUwmk',
    min_length: 10
  )
  def self.md5(str)
    ActiveSupport::Digest.hexdigest(str.to_s)
  end

  def self.sha1(str)

  end
end
