# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ManageUsers', type: :feature do
  before do
    @users = create_list(:user, 5)
    @admin = create(:admin)
  end

  context 'when user is an admin' do
    before do
      visit login_path

      fill_in 'Username', with: @admin.username
      fill_in 'Password', with: @admin.password

      click_button I18n.t('sessions.new.log_in')
    end

    it 'shows the users list' do
      visit users_path

      expect(page).to have_text @users[1].username
    end
  end

  context 'when user is not an admin' do
    before do
      visit login_path

      fill_in 'Username', with: @users[1].username
      fill_in 'Password', with: @users[1].password

      click_button I18n.t('sessions.new.log_in')
    end

    it 'shows an error' do
      visit users_path

      expect(page).to have_text I18n.t('users.admin_only.not_admin')
    end

    it 'doesn\'t show the user list' do
      visit users_path

      expect(page).not_to have_text @users[0].username
    end
  end
end
