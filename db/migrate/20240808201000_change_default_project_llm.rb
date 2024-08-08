# frozen_string_literal: true

class ChangeDefaultProjectLlm < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:projects, :default_llm, from: 'gpt3.5', to: 'gpt-4o-mini')
  end
end
