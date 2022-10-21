# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /new_user' do
    context 'when not logged in' do
      before { get new_user_path }

      it { is_expected.to redirect_to(login_path) }
    end

    context 'when logged in as a user' do
      before do
        login user
        get new_user_path
      end

      it { is_expected.to redirect_to(login_path) }
    end

    context 'when logged in as an admin' do
      before do
        login admin
        get new_user_path
      end

      it { is_expected.to render_template(:new) }
    end
  end

  describe 'GET /users' do
    context 'when not logged in' do
      before { get users_path }

      it { is_expected.to redirect_to(login_path) }
    end

    context 'when logged in as a user' do
      before do
        login user
        get users_path
      end

      it { is_expected.to redirect_to(login_path) }
    end

    context 'when logged in as an admin' do
      before do
        login admin
        get users_path
      end

      it { is_expected.to render_template(:index) }
    end
  end

  describe 'GET /users/:id/edit' do
    context 'when not logged in' do
      before { get edit_user_path(user) }

      it { is_expected.to redirect_to(login_path) }
    end

    context 'when logged in as another user' do
      before do
        login user
        get edit_user_path(other_user)
      end

      it { is_expected.to redirect_to(edit_user_path(user)) }
    end

    context 'when logged in as the user' do
      before do
        login user
        get edit_user_path(user)
      end

      it { is_expected.to render_template(:edit) }
    end

    context 'when logged in as an admin' do
      before do
        login admin
        get edit_user_path(user)
      end

      it { is_expected.to render_template(:edit) }
    end
  end

  describe 'PATCH /users/:id' do
    context 'when logged in as an admin' do
      before { login admin }

      it 'can change the admin flag' do
        patch user_path(user), params: { user: { admin: !user.admin? } }

        expect(User.find(user.id).admin?).to be !user.admin?
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
        patch user_path(user), params: { user: { admin: !user.admin? } }

        expect(User.find(user.id).admin?).to be user.admin?
      end

      it 'can update its password' do
        password = 'newpassword'

        patch user_path(user), params: { user: { password:,
                                                 password_confirmation:
                                                  password } }

        expect(User.find(user.id).authenticate(password)).to be_truthy
      end

      it "can't update another user's attributes" do
        patch user_path(other_user), params: { user: { email: 'nope@example.org' } }

        expect(User.find(other_user.id).email).not_to eq('nope@example.org')
      end
    end
  end

  describe 'GET /users/:id' do
    context 'when logged in as a user' do
      before { login user }

      it 'can see its own profile' do
        get user_path(user)

        expect(response).to render_template(:show)
      end

      it "can see another user's profile" do
        get user_path(other_user)

        expect(response).to render_template(:show)
      end
    end

    context 'when logged in as an admin' do
      before do
        login admin
      end

      it 'can see another user\'s profile' do
        get user_path(other_user)

        expect(response).to render_template(:show)
      end
    end
  end

  describe 'DELETE /users/:id' do
    context 'when not logged in' do
      before { delete user_path(user) }

      it { is_expected.to redirect_to login_path }

      it "doesn't delete the user" do
        expect(User.find(user.id)).not_to be_deleted
      end
    end

    context 'when logged in as a user' do
      before do
        login user
        delete user_path(user)
      end

      it { is_expected.to redirect_to login_path }

      it "doesn't delete the user" do
        expect(User.find(user.id)).not_to be_deleted
      end
    end

    context 'when logged in as an admin' do
      before do
        login admin
        delete user_path user
      end

      it 'deletes the user' do
        expect(User.find(user.id)).to be_deleted
      end
    end
  end
end
