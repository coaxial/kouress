# frozen_string_literal: true

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: "User #{@user.username} created"
    else
      render 'new'
    end
  end

  def index
    @users = User.all
  end
end
