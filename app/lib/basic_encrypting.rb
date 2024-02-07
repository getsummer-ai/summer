# OpenStruct will serialize to json without table
class BasicEncrypting
  attr_reader :sqids

  private_class_method :new

  def initialize
    # @type [Sqids]
    @sqids = Sqids.new(
      alphabet: 'R90cIx6eVsuqWXSCyQlNKjF4vT5pP1rLYdZG2t7nBDzHofEMJa38gbhiAOUwmk',
      min_length: 5
    )
  end

  class << self
    def instance
      @instance ||= new
    end

    def encode_array(value)
      instance.sqids.encode(value)
    end

    def decode_array(value, required_length)
      return nil if value.blank?
      res = instance.sqids.decode(value)
      nil if res.length != required_length
      res
    end

    def encode(value)
      instance.sqids.encode([value])
    end

    def decode(value)
      return nil if value.blank?
      arr = instance.sqids.decode(value)
      arr[0] if arr.present?
    end
  end
end
