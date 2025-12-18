# frozen_string_literal: true

module ExceptionFilter
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing,
                with: ->(e) { log_error(e) && render_api_error(ApiError::ParamMissingError.new(e.param)) }

    rescue_from ActiveRecord::RecordNotFound,
                with: ->(e) { log_error(e) && render_api_error(ApiError::NotFoundError.new) }

    rescue_from ActiveRecord::RecordInvalid,
                with: ->(e) { log_error(e) && render_api_error(ApiError::RecordInvalidError.new(e.record.errors)) }

    rescue_from ApiError::StandardError,
                with: ->(e) { log_error(e) && render_internal_error(e) }
  end

  private

  def log_error(error)
    Rails.logger.error(error)
  end

  def render_api_error(error)
    render json: error, status: error.status
  end

  def render_internal_error(err)
    api_error = if Rails.env.production?
                  ApiError::InternalServerError.new
                else
                  ApiError::InternalServerError.new(err.message)
                end
    render_api_error(api_error)
  end
end
