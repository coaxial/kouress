# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login', type: :feature do
  before do
    @user = create(:user)
  end

  context 'with valid credentials' do
    it 'logs the user in' do
      visit '/login'

      fill_in 'Username', with: @user.username
      fill_in 'Password', with: @user.password

      click_button I18n.t('sessions.new.log_in')

      expect(page).to have_text('Site#home')
    end
  end

  context 'with invalid credentials' do
    it 'warns about failure' do
      visit '/login'

      fill_in 'Username', with: 'test_user'
      fill_in 'Password', with: 'hunter2'

      click_button I18n.t('sessions.new.log_in')

      expect(page).to have_text(I18n.t('sessions.create.failure'))
    end
  end
end
