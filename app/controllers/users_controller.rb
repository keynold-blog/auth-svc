# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    raise ActionController::ParameterMissing, :test_param
  end
end
