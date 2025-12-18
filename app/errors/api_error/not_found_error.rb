# frozen_string_literal: true

module ApiError
  class NotFoundError < StandardError
    def initialize
      super(code: :not_found, message: 'Resource not found', status: :not_found)
    end
  end
end
