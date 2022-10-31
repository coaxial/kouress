# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :redirect_to_own, only: :edit
  before_action :override_user, only: %i[edit update]
  before_action :admin_user, only: %i[index destroy new create]

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

  def edit; end

  def update
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
    @user = User.find(params[:id].to_i)
    if @user.destroy
      redirect_to users_path, notice: t('.success')
    else
      flash.now[:alert] = t('.failure')
      render 'index', status: :unprocessable_entity
    end
  end

  private

  def admin_user
    redirect_to login_url, alert: t('users.admin_user.not_allowed'), status: :see_other unless current_user.admin?
  end

  # Selects the requested User for admins, or their own for users
  def override_user
    @user = User.find(current_user.id) if current_user
    @user = User.find(params[:id].to_i) if current_user.admin?
  end

  # If the user tries to edit another profile and isn't an admin, redirect to
  # their own profile instead
  def redirect_to_own
    return if current_user&.admin? || params[:id].to_i == current_user&.id

    redirect_to edit_user_path(current_user),
                params:,
                status: :see_other
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
