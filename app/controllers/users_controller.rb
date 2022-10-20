# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin_only, except: %i[show edit update]
  before_action :self_or_admin_only, only: %i[show edit update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: t('.success', username: @user.username)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(update_params.to_h)
      redirect_to edit_user_path, notice: t('.success')
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])

    if @user.update(deleted: !@user.deleted?)
      redirect_to users_path, notice: t('.success', operation:)
    else
      flash.now[:alert] = t('failure', operation:)
      render 'index', status: :unprocessable_entity
    end
  end

  private

  def operation
    @user.deleted? ? t('.deleted') : t('.restored')
  end

  def admin_only
    return if @current_user.admin?

    redirect_to login_url, alert: t('users.admin_only.failure')
  end

  def self_or_admin_only
    return if @current_user.id == params[:id].to_i || @current_user.admin?

    redirect_to login_url, alert: t('users.self_or_admin_only.failure')
  end

  def user_params
    permitted_params = %i[username email password]
    permitted_params << :admin if @current_user.admin?

    params.require(:user).permit(permitted_params)
  end

  def update_params
    user_params.except(:username)
  end
end
