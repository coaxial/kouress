# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :require_login

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def require_login
    redirect_to login_url, status: :see_other, alert: t('application.require_login.log_in') unless logged_in?
  end
end
