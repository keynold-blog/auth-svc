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
FactoryBot.define do
  factory :signing_key do
    
  end
end
