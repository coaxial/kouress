# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logout' do
  context 'when the user is logged in' do
    before do
      user = create(:user)

      visit login_path

      fill_in 'Username', with: user.username
      fill_in 'Password', with: user.password

      click_button I18n.t('sessions.new.log_in')
    end

    it 'logs the user out' do
      visit logout_path

      expect(page).to have_text(I18n.t('sessions.new.title'))
    end
  end

  context 'when the user is not logged in' do
    it 'does nothing' do
      visit logout_path

      expect(page).not_to have_text(I18n.t('application.authorize.not_authorized'))
    end
  end
end
