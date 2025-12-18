# frozen_string_literal: true

class CreateSigningKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :signing_keys, id: :uuid do |t|
      t.string :kid, null: false, index: { unique: true }
      t.text :public_key, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end
  end
end
