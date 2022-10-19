# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

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

      it 'shows the user creation page' do
        expect(response).to render_template(:new)
      end
    end
  end

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
        login admin

        get users_path
      end

      it 'shows the users list page' do
        expect(response).to render_template(:index)
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
    context 'when logged in as an admin' do
      before do
        login admin
      end

      it 'can change the admin flag' do
        patch user_path(user), params: { user: { is_admin: !user.is_admin } }

        expect(User.find(user.id).is_admin).to be !user.is_admin
      end

      it 'can update a user\'s password' do
        password = 'newpassword'

        patch user_path(user), params: { user: { password:,
                                                 password_confirmation:
                                                  password } }

        expect(User.find(user.id).authenticate(password)).to be_truthy
      end
    end

    context 'when logged in as a user' do
      before { login user }

      it 'cannot change its admin flag' do
        patch user_path(user), params: { user: { is_admin: !user.is_admin } }

        expect(User.find(user.id).is_admin).to be user.is_admin
      end

      it 'can update its password' do
        password = 'newpassword'

        patch user_path(user), params: { user: { password:,
                                                 password_confirmation:
                                                  password } }

        expect(User.find(user.id).authenticate(password)).to be_truthy
      end

      it "can't update another user's attributes" do
        other_user = create(:user)

        get user_path(other_user)
      end
    end
  end

  describe 'GET /users/:id' do
    context 'when logged in as a user' do
      before do
        login user
      end

      it 'can see its own profile' do
        get user_path(user)

        expect(response).to render_template(:show)
      end

      it "can't see another user's profile" do
        other_user = create(:user)

        get user_path(other_user)

        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as an admin' do
      before do
        login admin
      end

      it 'can see another user\'s profile' do
        other_user = create(:user)

        get user_path(other_user)

        expect(response).to render_template(:show)
      end
    end
  end
end
