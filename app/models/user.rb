# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :uuid             not null, primary key
#  email              :string           not null
#  encrypted_password :string           not null
#  failed_attempts    :integer          default(0)
#  last_sign_in_at    :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class User < ApplicationRecord
end
