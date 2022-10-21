# frozen_string_literal: true

module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    reset_session

    # This clears the instance variable set in ApplicationController
    @current_user = nil # rubocop:disable Rails/HelperInstanceVariable
  end

  def logged_in?
    !current_user.nil?
  end
end
