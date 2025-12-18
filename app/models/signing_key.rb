# frozen_string_literal: true

# == Schema Information
#
# Table name: signing_keys
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(FALSE), not null
#  kid        :string           not null
#  public_key :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_signing_keys_on_kid  (kid) UNIQUE
#
class SigningKey < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates :kid, presence: true, uniqueness: true
  validates :public_key, presence: true
end
