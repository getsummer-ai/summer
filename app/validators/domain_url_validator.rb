# frozen_string_literal: true
class DomainUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if url_valid?(value)
    record.errors.add(attribute, (options[:message] || 'must be a valid url'))
  end

  def url_valid?(url)
    %r{^(((http|https)://|)?[a-z0-9]+([\-\.][a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(/.*)?)$}.match?(url)
  end
end
