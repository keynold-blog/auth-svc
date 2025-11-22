# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.datetime :last_sign_in_at
      t.integer :failed_attempts, default: 0
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
