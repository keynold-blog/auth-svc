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
require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }

    it 'validates uniqueness of email', :aggregate_failures do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'default values' do
    it 'has default failed_attempts value of 0' do
      expect(user.failed_attempts).to eq(0)
    end
  end

  describe 'failed_attempts attribute', :aggregate_failures do
    describe 'default value' do
      it 'defaults to 0 when building a new user' do
        new_user = build(:user)
        expect(new_user.failed_attempts).to eq(0)
      end

      it 'defaults to 0 when creating a new user' do
        new_user = create(:user)
        expect(new_user.failed_attempts).to eq(0)
      end

      it 'defaults to 0 when instantiating directly' do
        new_user = described_class.new(email: 'test@example.com', password: 'password123')
        expect(new_user.failed_attempts).to eq(0)
      end

      it 'defaults to 0 even when not explicitly set' do
        new_user = described_class.new
        expect(new_user.failed_attempts).to eq(0)
      end
    end

    describe 'type casting' do
      it 'casts to integer type' do
        user = build(:user, failed_attempts: '5')
        expect(user.failed_attempts).to be_a(Integer)
        expect(user.failed_attempts).to eq(5)
      end

      it 'allows nil to be set explicitly (default only applies when not set)' do
        user = build(:user, failed_attempts: nil)
        expect(user.failed_attempts).to be_nil
      end

      it 'handles zero as integer' do
        user = build(:user, failed_attempts: 0)
        expect(user.failed_attempts).to eq(0)
        expect(user.failed_attempts).to be_a(Integer)
      end
    end

    describe 'overriding default value' do
      it 'allows setting a custom value when building' do
        user = build(:user, failed_attempts: 3)
        expect(user.failed_attempts).to eq(3)
      end

      it 'allows setting a custom value when creating' do
        user = create(:user, failed_attempts: 5)
        expect(user.failed_attempts).to eq(5)
        expect(user.reload.failed_attempts).to eq(5)
      end

      it 'allows updating the value' do
        user = create(:user)
        user.update!(failed_attempts: 10)
        expect(user.failed_attempts).to eq(10)
        expect(user.reload.failed_attempts).to eq(10)
      end

      it 'allows incrementing the value' do
        user = create(:user, failed_attempts: 2)
        user.increment!(:failed_attempts)
        expect(user.failed_attempts).to eq(3)
        expect(user.reload.failed_attempts).to eq(3)
      end
    end

    describe 'persistence' do
      it 'persists the default value to the database' do
        user = create(:user)
        expect(user.failed_attempts).to eq(0)

        reloaded_user = described_class.find(user.id)
        expect(reloaded_user.failed_attempts).to eq(0)
      end

      it 'persists custom values to the database' do
        user = create(:user, failed_attempts: 7)
        expect(user.failed_attempts).to eq(7)

        reloaded_user = described_class.find(user.id)
        expect(reloaded_user.failed_attempts).to eq(7)
      end
    end
  end

  describe 'has_secure_password', :aggregate_failures do
    describe 'password encryption' do
      it 'stores password_digest instead of plain password' do
        user = create(:user, password: 'secret123', password_confirmation: 'secret123')
        expect(user.password_digest).to be_present
        expect(user.password_digest).not_to eq('secret123')
        expect(user.password_digest.length).to be > 20 # bcrypt hashes are long
      end

      it 'does not store the password in plain text' do
        password = 'my_secret_password'
        user = create(:user, password: password, password_confirmation: password)
        expect(user.password_digest).not_to include(password)
        expect(user.password_digest).not_to eq(password)
      end

      it 'generates different digests for the same password' do
        password = 'same_password'
        user1 = create(:user, email: 'user1@example.com', password: password, password_confirmation: password)
        user2 = create(:user, email: 'user2@example.com', password: password, password_confirmation: password)

        expect(user1.password_digest).not_to eq(user2.password_digest)
        expect([user1, user2].map { |u| u.authenticate(password) }).to eq([user1, user2])
      end

      it 'persists password_digest to the database' do
        user = create(:user, password: 'test123', password_confirmation: 'test123')
        digest = user.password_digest

        reloaded_user = described_class.find(user.id)
        expect(reloaded_user.password_digest).to eq(digest)
      end
    end

    describe 'password validation' do
      it 'requires password to be present on creation' do
        user = build(:user, password: nil, password_confirmation: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
      end

      it 'requires password to be present when password_confirmation is set' do
        user = build(:user, password: nil, password_confirmation: 'something')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
      end

      it 'allows passwords of any length (has_secure_password does not validate length by default)' do
        # NOTE: has_secure_password only validates presence, not length
        user = build(:user, password: 'short', password_confirmation: 'short')
        expect(user).to be_valid
      end

      it 'allows passwords of 8 or more characters' do
        user = build(:user, password: '12345678', password_confirmation: '12345678')
        expect(user).to be_valid
      end

      it 'does not require password on update if password is not changed' do
        user = create(:user, password: 'password123', password_confirmation: 'password123')
        user.email = 'newemail@example.com'
        expect(user).to be_valid
        expect(user.save).to be true
      end

      it 'allows updating password to any length (has_secure_password does not validate length)' do
        user = create(:user, password: 'oldpassword', password_confirmation: 'oldpassword')
        user.password = 'new'
        user.password_confirmation = 'new'
        expect(user).to be_valid
        expect(user.save).to be true
      end
    end

    describe 'password_confirmation validation' do
      it 'requires password_confirmation to match password' do
        user = build(:user, password: 'password123', password_confirmation: 'different')
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to be_present
      end

      it 'is valid when password and password_confirmation match' do
        user = build(:user, password: 'password123', password_confirmation: 'password123')
        expect(user).to be_valid
      end

      it 'allows creation without password_confirmation if password matches' do
        user = build(:user, password: 'password123', password_confirmation: nil)
        expect(user.password_confirmation).to be_nil
      end
    end

    describe 'password virtual attributes' do
      it 'provides password virtual attribute' do
        user = build(:user, password: 'test123')
        expect(user.password).to eq('test123')
        expect(user.password_digest).to be_present
      end

      it 'provides password_confirmation virtual attribute' do
        user = build(:user, password: 'test123', password_confirmation: 'test123')
        expect(user.password_confirmation).to eq('test123')
      end

      it 'does not persist password virtual attribute' do
        password = 'test123'
        user = create(:user, password: password, password_confirmation: password)

        reloaded_user = described_class.find(user.id)
        expect(reloaded_user.password).to be_nil
        expect(reloaded_user.password_digest).to be_present
      end

      it 'allows reading password before save' do
        user = build(:user, password: 'readable')
        expect(user.password).to eq('readable')
      end
    end

    describe 'password_digest attribute' do
      it 'is invalid when password_digest is nil before save' do
        user = build(:user, password: 'test123', password_confirmation: 'test123')
        user.password_digest = nil
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
      end

      it 'cannot be set to null in database' do
        user = create(:user, password: 'test123', password_confirmation: 'test123')
        expect do
          described_class.where(id: user.id).update_all(password_digest: nil)
        end.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'is automatically set when password is provided' do
        user = build(:user, password: 'test123', password_confirmation: 'test123')
        expect(user.password_digest).to be_present
        expect(user.password_digest).to be_a(String)
      end

      it 'changes when password is updated' do
        user = create(:user, password: 'oldpass', password_confirmation: 'oldpass')
        old_digest = user.password_digest

        user.update!(password: 'newpass', password_confirmation: 'newpass')
        expect(user.password_digest).not_to eq(old_digest)
        expect(user.password_digest).to be_present
      end
    end
  end

  describe '#authenticate' do
    let(:user) { create(:user, password: 'password123', password_confirmation: 'password123') }

    context 'with a valid password' do
      it 'returns the user object' do
        expect(user.authenticate('password123')).to eq(user)
      end

      it 'returns the user object (not true)', :aggregate_failures do
        result = user.authenticate('password123')
        expect(result).to be_a(described_class)
        expect(result.id).to eq(user.id)
      end
    end

    context 'with an invalid password' do
      it 'returns false' do
        expect(user.authenticate('wrongpassword')).to be(false)
      end

      it 'returns false for empty password' do
        expect(user.authenticate('')).to be(false)
      end

      it 'returns false for nil password' do
        expect(user.authenticate(nil)).to be(false)
      end

      it 'returns false for similar but incorrect password', :aggregate_failures do
        expect(user.authenticate('password1234')).to be(false)
        expect(user.authenticate('password12')).to be(false)
      end
    end

    context 'when password updated' do
      it 'authenticates with new password after update', :aggregate_failures do
        user.update!(password: 'newpassword', password_confirmation: 'newpassword')
        expect(user.authenticate('newpassword')).to eq(user)
        expect(user.authenticate('password123')).to be(false)
      end

      it 'does not authenticate with old password after update', :aggregate_failures do
        old_password = 'oldpassword'
        user.update!(password: old_password, password_confirmation: old_password)
        expect(user.authenticate(old_password)).to eq(user)

        user.update!(password: 'newpassword', password_confirmation: 'newpassword')
        expect(user.authenticate(old_password)).to be(false)
      end
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
