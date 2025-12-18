# frozen_string_literal: true

# https://scalablearchitect.com/rsa-jwt-encryption-and-key-rotation-in-enterprise-gitops-a-practical-guide
module Jwt
  class KeyManagerService < ApplicationService
    class << self
      def current_signing_key_record
        @current_signing_key_record ||= SigningKey.active.order(updated_at: :desc).first
      end

      def current_kid
        current_signing_key_record&.kid
      end

      def current_private_key_pem
        kid = current_kid
        return if kid.nil?

        ENV.fetch(private_key_env_name(kid))
      end

      def current_private_key
        pem = current_private_key_pem
        raise MissingPrivateKey, "#{private_key_env_name(current_kid)} missing" if pem.nil?

        OpenSSL::PKey::RSA.new(pem)
      end

      def public_key_pem_for(kid)
        record = SigningKey.find_by(kid: kid)
        return record.public_key if record.present?

        ENV.fetch(public_key_env_name(kid))
      end

      def public_key_for(kid)
        pem = public_key_pem_for(kid)
        return nil unless pem

        OpenSSL::PKey::RSA.new(pem)
      end

      def jwks_keys
        SigningKey.order(created_at: :desc).map do |sk|
          {
            kid: sk.kid,
            kty: 'RSA',
            alg: 'RS256',
            use: 'sig',
            n: Base64.urlsafe_encode64(sk.public_key_object.n.to_s(2), padding: false),
            e: Base64.urlsafe_encode64(sk.public_key_object.e.to_s(2), padding: false),
            public_key: sk.public_key,
          }
        end
      end

      def activate_kid!(kid)
        ActiveRecord::Base.transaction do
          SigningKey.update_all(active: false)
          key = SigningKey.find_by!(kid: kid)
          key.update!(active: true)
          @current = nil
        end
      end

      def private_key_env_name(kid)
        "JWT_PRIVATE_KEY_#{sanitize_env(kid)}"
      end

      def public_key_env_name(kid)
        "JWT_PUBLIC_KEY_#{sanitize_env(kid)}"
      end

      def sanitize_env(kid)
        kid.upcase.gsub(/[^A-Z0-9]/, '_')
      end
    end
  end
end
