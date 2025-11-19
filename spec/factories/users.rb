# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    encrypted_password { FFaker::Internet.password }
  end
end
