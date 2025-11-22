# frozen_string_literal: true

require 'rails_helper'

# A dummy controller to test the concern
class MinimalTestController < ApplicationController
  include ExceptionFilter
  include FactoryBot::Syntax::Methods
  include RSpec::Mocks::ExampleMethods

  def param_missing
    raise ActionController::ParameterMissing, :test_param
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end

  def record_invalid
    user = User.new
    user.valid?
    raise ActiveRecord::RecordInvalid, user
  end

  def record_not_destroyed
    user = build_stubbed(:user)
    allow(user).to receive(:errors).and_return(ActiveModel::Errors.new(user).tap { |e|
      e.add(:base, 'cannot be destroyed')
    })
    raise ActiveRecord::RecordNotDestroyed.new('Failed to destroy the record', user)
  end

  def some_other_api_error
    raise TempApiError
  end

  def internal_server_error
    raise ApiError::StandardError.new(message: 'A test error')
  end
end

class TempApiError < ApiError::StandardError
  def initialize
    super(code: :temp_error, message: 'Temp error', status: :bad_gateway)
  end
end

RSpec.describe ExceptionFilter, type: :controller do
  controller(MinimalTestController) {} # rubocop:disable Lint/EmptyBlock
  before do
    routes.draw do
      get 'param_missing' => 'minimal_test#param_missing'
      get 'not_found' => 'minimal_test#not_found'
      get 'record_invalid' => 'minimal_test#record_invalid'
      get 'record_not_destroyed' => 'minimal_test#record_not_destroyed'
      get 'some_other_api_error' => 'minimal_test#some_other_api_error'
      get 'internal_server_error' => 'minimal_test#internal_server_error'
    end
  end

  describe 'ExceptionFilter' do
    around do |example|
      original_show_exceptions =
        Rails.application.config.action_dispatch.show_exceptions
      begin
        Rails.application.config.action_dispatch.show_exceptions = true
        example.run
      ensure
        Rails.application.config.action_dispatch.show_exceptions = original_show_exceptions
      end
    end

    context 'when ActionController::ParameterMissing is raised' do
      it 'renders a param missing error', :aggregate_failures do
        get :param_missing
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['code']).to eq('param_missing')
        expect(json['message']).to include('test_param')
      end
    end

    context 'when ActiveRecord::RecordNotFound is raised' do
      it 'renders a not found error', :aggregate_failures do
        get :not_found
        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['code']).to eq('not_found')
      end
    end

    context 'when ActiveRecord::RecordInvalid is raised' do
      it 'renders a record invalid error', :aggregate_failures do
        get :record_invalid
        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json).to include('code' => 'record_invalid', 'errors' => be_present)
        expect(json['errors']['email']).to include("can't be blank")
      end
    end

    context 'when a subclass of APIError::StandardError is raised' do
      it 'renders the error using render_api_standard_error', :aggregate_failures do
        get :some_other_api_error
        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['code']).to eq('internal_server_error')
      end
    end

    context 'when StandardError is raised and in production' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it 'renders an internal server error without details', :aggregate_failures do
        get :internal_server_error
        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['code']).to eq('internal_server_error')
        expect(json['message']).to eq('Something went wrong')
      end
    end

    context 'when StandardError is raised and not in production' do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it 'renders an internal server error with details', :aggregate_failures do
        get :internal_server_error
        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['code']).to eq('internal_server_error')
        expect(json['message']).to eq('A test error')
      end
    end
  end

  describe '#log_error' do
    let(:error) { StandardError.new('Test message') }

    it 'logs the error object', :aggregate_failures do
      allow(error).to receive(:backtrace).and_return(['line 1', 'line 2'])
      allow(Rails.logger).to receive(:error) # Setup spy
      controller.send(:log_error, error)
      expect(Rails.logger).to have_received(:error).with(error)
    end

    it 'does not fail if backtrace is nil', :aggregate_failures do
      allow(error).to receive(:backtrace).and_return(nil)
      allow(Rails.logger).to receive(:error) # Setup spy
      expect { controller.send(:log_error, error) }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(error)
    end
  end
end
