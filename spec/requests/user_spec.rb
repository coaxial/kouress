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
  end

  describe 'POST /users' do
    context 'when not logged in' do
      before do
        post users_path
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
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
  end

  describe 'EDIT /users/:id/edit' do
    context 'when not logged in' do
      before do
        @user = create(:user)
        get edit_user_path(@user)
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
