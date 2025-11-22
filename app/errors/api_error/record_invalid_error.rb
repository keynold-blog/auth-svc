# frozen_string_literal: true

module ApiError
  class RecordInvalidError < StandardError
    def initialize(errors)
      super(
        code: :record_invalid,
        message: 'Record invalid',
        status: :unprocessable_content,
        errors: errors
      )
    end
  end
end
