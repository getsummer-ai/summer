# OpenStruct will serialize to json without table
module Hashing
  def self.md5(str)
    ActiveSupport::Digest.hexdigest(str.to_s)
  end

  def self.sha1(str)

  end
end
