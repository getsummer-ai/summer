# frozen_string_literal: true

class AddStripeDetailsToProjects < ActiveRecord::Migration[7.1]
  def change
    change_table :projects do |t|
      # t.string :stripe_id
      t.jsonb :stripe, default: {}, null: false
    end
  end
end
