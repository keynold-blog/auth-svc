# frozen_string_literal: true

module ApiError
  class ParamMissingError < StandardError
    def initialize(param)
      super(
        code: :param_missing,
        message: "Parameter missing: #{param}",
        status: :bad_request
      )
    end
  end
end
