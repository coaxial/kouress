# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CreateUsers' do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:new_user) { build(:user) }
  let(:new_user_form) do
    {
      Username: new_user.username,
      Email: new_user.username,
      Password: new_user.password,
      'Password confirmation': new_user.password
    }
  end

  context 'when user is not an admin' do
    before do
      login user
      visit new_user_path
    end

    it 'asks to login' do
      expect(page).to have_text(I18n.t('users.admin_user.not_allowed'))
    end
  end

  context 'when user is an admin' do
    before do
      login admin
      visit new_user_path
    end

    it 'can create a new user' do
      fill_form(new_user_form, 'shared.users.form.create')

      expect(page).to have_text(new_user.username)
    end
  end
end
