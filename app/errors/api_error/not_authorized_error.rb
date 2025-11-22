# frozen_string_literal: true

module ApiError
  class NotAuthorizedError < StandardError
    def initialize
      super(code: :not_authorized, message: 'Not authorized', status: :unauthorized)
    end
  end
end
