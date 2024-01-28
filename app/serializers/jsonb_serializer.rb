# frozen_string_literal: true
class JsonbSerializer
  def self.dump(obj = {})
    return JSON.parse(obj) if obj.is_a?(String)
    obj
  end

  # @return [Hash,Array]
  def self.load(obj)
    return nil if obj.blank?
    case obj
    when Hash
      obj.with_indifferent_access
    when Array
      obj.map { |item| item.is_a?(Hash) ? item.with_indifferent_access : item }
    when String
      load JSON.parse(obj)
    else
      obj
    end
  end
end
