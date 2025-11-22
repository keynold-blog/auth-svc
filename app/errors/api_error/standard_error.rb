# frozen_string_literal: true

module ApiError
  class StandardError < ::StandardError
    attr_reader :code, :message, :status, :errors

    def initialize(
      code: :internal_server_error,
      message: 'Internal server error',
      status: :internal_server_error,
      errors: nil
    )
      super(message)
      @code = code
      @message = message
      @status = status
      @errors = errors
    end

    def as_json(_opts = {})
      result = {
        code: code.to_s,
        message:,
      }
      result[:errors] = errors.to_hash if errors.respond_to?(:to_hash)
      result.compact
    end

    def to_json(_opts = {})
      as_json.to_json
    end
  end
end
