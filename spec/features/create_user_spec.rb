# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CreateUsers', type: :feature do
  context 'when user is not an admin' do
    before do
      user = create(:user)
      login user
      visit new_user_path
    end

    it 'asks to login' do
      expect(page).to have_text(I18n.t('users.admin_only.failure'))
    end
  end

  context 'when user is an admin' do
    before do
      admin = create(:admin)
      login admin
      visit new_user_path
    end

    it 'can create a new user' do
      user = build(:user)

      fill_form(
        { Username: user.username, Email: user.username, Password: user.password,
          'Password confirmation': user.password }, 'users.new.create'
      )

      expect(page).to have_text(user.username)
    end
  end
end
