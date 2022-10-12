class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Successfully logged in"
    else
      flash.now.alert = "Invalid credentials or user not found"
      render "new"
    end
  end

  def destroy
    reset_session
  end
end
