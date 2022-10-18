# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_only, except: :edit
  before_action :self_or_admin_only, only: :edit

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

  def edit
    @user = User.find(params[:id])
  end

  private

  def admin_only
    return if @current_user.is_admin

    redirect_to login_url, alert: t('users.admin_only.failure')
  end

  def self_or_admin_only
    return if @current_user.id == params[:id].to_i || @current_user.is_admin

    redirect_to login_url, alert: t('users.self_or_admin_only.failure')
  end
end
