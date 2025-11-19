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
require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it 'requires email' do
      user = build(:user, email: nil)

      expect { user.save! }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires encrypted_password' do
      user = build(:user, encrypted_password: nil)

      expect { user.save! }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe 'default values' do
    let_it_be(:user) { create(:user) }
    let(:new_user) { create(:user) }

    it 'has default failed_attempts value of 0' do
      expect(user.failed_attempts).to eq(0)
    end

    it 'sets failed_attempts to 0 if not explicitly provided' do
      user_without_failed_attempts = create(:user, failed_attempts: nil)
      expect(user_without_failed_attempts.failed_attempts).to eq(0)
    end

    it 'allows failed_attempts to be updated' do
      new_user.update!(failed_attempts: 5)
      expect(new_user.failed_attempts).to eq(5)
    end

    it 'does not affect other users when updating failed_attempts' do
      new_user.update!(failed_attempts: 5)
      expect(user.reload.failed_attempts).to eq(0)
    end
  end

  describe 'uuid generation' do
    let(:user) { create(:user) }

    it 'generates uuid v7 for id', :aggregate_failures do
      expect(user.id).to be_present
      expect(user.id.to_s).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
    end
  end

  describe 'attributes' do
    let(:user) { create(:user) }

    it 'allows updating failed_attempts' do
      user.update!(failed_attempts: 3)
      expect(user.failed_attempts).to eq(3)
    end

    it 'allows updating last_sign_in_at' do
      sign_in_time = Time.current
      user.update!(last_sign_in_at: sign_in_time)
      expect(user.last_sign_in_at.to_i).to eq(sign_in_time.to_i)
    end

    it 'has timestamps', :aggregate_failures do
      expect(user.created_at).to be_present
      expect(user.updated_at).to be_present
    end
  end

  describe 'creation' do
    let(:user) { build(:user) }

    it 'creates user with valid attributes', :aggregate_failures do
      expect(user.save).to be true
      expect(user).to be_persisted
      expect(user.id).to be_present
    end
  end
end
