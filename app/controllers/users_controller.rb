# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_only

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

  def edit; end

  private

  def admin_only
    redirect_to login_url, alert: t('users.admin_only.not_admin') unless @current_user.is_admin
  end
end
