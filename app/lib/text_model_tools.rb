# OpenStruct will serialize to json without table
module TextModelTools
  def self.estimate_max_tokens(text)
    word_count = text.split.count
    char_count = text.length
    tokens_count_word_est = word_count.to_f / 0.75
    tokens_count_char_est = char_count.to_f / 4.0

    # Include additional tokens for spaces and punctuation marks
    additional_tokens = text.scan(/[\s.,!?;]/).length

    tokens_count_word_est += additional_tokens
    tokens_count_char_est += additional_tokens
    [tokens_count_word_est, tokens_count_char_est].max.to_i
  end
end
