# frozen_string_literal: true

module ApiError
  class InternalServerError < StandardError
    def initialize(message = nil)
      super(
        code: :internal_server_error,
        message: message || 'Something went wrong',
        status: :internal_server_error
      )
    end
  end
end
