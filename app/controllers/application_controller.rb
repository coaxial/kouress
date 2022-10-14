# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :authorize

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to login_url, alert: t('application.authorize.not_authorized') if current_user.nil?
  end
end
