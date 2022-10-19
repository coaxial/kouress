# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    context 'when not logged in' do
      before do
        get users_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as a user' do
      before do
        user = create(:user)
        post sessions_path, params: { username: user.username,
                                      password: user.password }

        get users_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as an admin' do
      before do
        admin = create(:admin)
        post sessions_path, params: { username: admin.username,
                                      password: admin.password }

        get users_path
      end

      it 'shows the management page' do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'POST /users' do
    context 'when not logged in' do
      before do
        post users_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end

      it 'cannot update the is_admin flag' do
        user = create(:user)

        patch user_path(user), params: { user: { is_admin: true } }

        expect(User.find(user.id).is_admin).to be false
      end
    end

    context 'when logged in as a user' do
      before do
        user = create(:user)
        post sessions_path, params: { username: user.username,
                                      password: user.password }

        post users_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as an admin' do
      before do
        admin = create(:admin)
        post sessions_path, params: { username: admin.username,
                                      password: admin.password }

        post users_path
      end

      it 'shows the create user page' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /new_user' do
    context 'when not logged in' do
      before do
        get new_user_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as a user' do
      before do
        user = create(:user)
        post sessions_path, params: { username: user.username,
                                      password: user.password }

        get new_user_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as an admin' do
      before do
        admin = create(:admin)
        post sessions_path, params: { username: admin.username,
                                      password: admin.password }

        get new_user_path
      end

      it 'shows the management page' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /users/:id/edit' do
    context 'when not logged in' do
      before do
        @user = create(:user)
        get edit_user_path(@user)
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as another user' do
      before do
        users = create_list(:user, 2)
        post sessions_path, params: { username: users[0].username,
                                      password: users[0].password }

        get edit_user_path(users[1])
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in as the user' do
      before do
        users = create_list(:user, 2)
        post sessions_path, params: { username: users[0].username,
                                      password: users[0].password }

        get edit_user_path(users[0])
      end

      it 'shows the edit page' do
        expect(response).to render_template(:edit)
      end
    end

    context 'when logged in as an admin' do
      before do
        user = create(:user)
        admin = create(:admin)
        post sessions_path, params: { username: admin.username,
                                      password: admin.password }

        get edit_user_path(user)
      end

      it 'shows the edit page' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PATCH /users/:id' do
    before do
      @user = create(:user)
      @admin = create(:admin)
    end

    context 'when logged in as an admin' do
      before do
        post sessions_path, params: { username: @admin.username,
                                      password: @admin.password }
      end

      it 'can change the admin flag' do
        patch user_path(@user), params: { user: { is_admin: !@user.is_admin } }

        expect(User.find(@user.id).is_admin).to be !@user.is_admin
      end
    end

    context 'when logged in as a user' do
      before do
        post sessions_path, params: { username: @user.username,
                                      password: @user.password }
      end

      it 'cannot change its admin flag' do
        patch user_path(@user), params: { user: { is_admin: !@user.is_admin } }

        expect(User.find(@user.id).is_admin).to be @user.is_admin
      end
    end
  end
end
