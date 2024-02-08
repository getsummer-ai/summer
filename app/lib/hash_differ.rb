# frozen_string_literal: true

# Extracted from file activesupport/lib/active_support/core_ext/hash/diff.rb
# This method deprecated in Rails.

class HashDiffer
  attr_accessor :base, :modified

  def initialize(base = {}, modified = {})
    @base = base.to_h
    @modified = modified.to_h
  end

  def to_h
    changed_attributes = modified.reject { |key, value| value == base[key] }
    base.reject { |key, _val| modified.key?(key) }.each_key do |key|
      changed_attributes[key] = nil
    end
    changed_attributes
  end

  def deep_diff
    a = @base
    b = @modified
    (a.keys | b.keys).each_with_object({}) do |k, diff|
      next if a[k] == b[k]
      diff[k] =
        if a[k].is_a?(Hash) && b[k].is_a?(Hash)
          self.class.new(a[k], b[k]).deep_diff
        else
          b[k]
        end
      diff
    end
  end
end
