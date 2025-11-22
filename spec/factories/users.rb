# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email           :string           not null
#  failed_attempts :integer          default(0)
#  last_sign_in_at :datetime
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
