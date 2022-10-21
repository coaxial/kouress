# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create destroy]

  def new; end

  def create
    user = User.find_by(username: params[:username].downcase)

    authenticate_or_fail(user)
  end

  def destroy
    log_out
    redirect_to login_url, status: :see_other
  end

  private

  def authenticate_or_fail(user)
    if user&.authenticate(params[:password])
      reset_session
      log_in(user)
      redirect_to root_url, notice: t('.success')
    else
      flash.now.alert = t('.failure')
      render 'new', status: :unprocessable_entity
    end
  end
end
