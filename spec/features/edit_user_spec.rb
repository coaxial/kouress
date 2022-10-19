# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EditUsers', type: :feature do
  context 'when user is not an admin' do
    before do
      user = create(:user)
      login(user)
      visit edit_user_path(user)
    end

    it 'doesnt show is_admin status' do
      expect(page).not_to have_field('user_is_admin')
    end

    it 'can update email' do
      fill_in 'Email', with: 'newemail@example.org'
      click_button I18n.t('users.edit.update')

      expect(page).to have_text(I18n.t('users.update.success'))
    end

    it 'can update password' do
      fill_in 'Password', with: 'evenbetterpassword'
      click_button I18n.t('users.edit.update')

      expect(page).to have_text(I18n.t('users.update.success'))
    end
  end

  context 'when user is an admin' do
    before do
      admin = create(:admin)
      user = create(:user)
      login(admin)
      visit edit_user_path(user)
    end

    it 'can update is_admin status' do
      expect(page).to have_field('user_is_admin')
    end

    it 'can update email' do
      fill_in 'Email', with: 'newemail@example.org'
      click_button I18n.t('users.edit.update')

      expect(page).to have_text(I18n.t('users.update.success'))
    end

    it 'can update password' do
      fill_in 'Password', with: 'evenbetterpassword'
      click_button I18n.t('users.edit.update')

      expect(page).to have_text(I18n.t('users.update.success'))
    end
  end
end
